require 'rubygems'
require 'sinatra'
require 'httparty'
require 'digest/md5'

class Tick
  include HTTParty
  base_uri 'https://globalpersonals.tickspot.com'

  def initialize(u, p)
    @auth = {:email => u, :password => p}
  end

  def users()
    self.class.get("/api/users", :query => @auth)['users']
  end

  def project(id, options = {})
    options[:project_id] ||= id
    self.class.get("/api/projects", :query => @auth.merge(options))['entries']
  end

  def entries(options = {})
    self.class.get("/api/entries", :query => @auth.merge(options))['entries']
  end
end

User = Struct.new(:name, :email) do
  def image
    'https://gravatar.com/avatar/' + Digest::MD5.hexdigest(self.email)
  end
end

configure do
  # load config
  config = YAML.load(File.read('config.yml'))

  # don't forget to set env variables with an admin tick account
  username = ENV['TICKBOARD_USERNAME']
  password = ENV['TICKBOARD_PASSWORD']

  # set up tick object for use in subsequent requests
  @@tick = Tick.new(username, password)

  # we can store the list of users which will be static unless we restart
  @@tick_users = @@tick.users.find_all{|u| !config['ignore'].include?(u['email'])}
end

get '/' do
  # request latest hours from tick
  entries  = @@tick.entries(:start_date => Date.today.to_s, 
                            :end_date   => Date.today.to_s).entries.group_by{|d| d['user_id']}

  # total up hours for each user and construct an array of image urls for the view
  @users = []
  for u in @@tick_users
    hours = entries[u['id']] || [{'hours' => 0}]
    total_hours = hours.collect{|h| h['hours']}.inject(:+)
		perc = (total_hours/7.5*100).to_i
    # add them to the naughty list if they're not yet at 100% of their time
    @users.push User.new("#{u['first_name']} #{u['last_name']}", u['email']) if perc < 100
  end
  
  erb :index
end
