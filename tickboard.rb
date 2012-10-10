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

  # total up hours for each user and construct an array of user objects for the view
  @users = []
  for u in @@tick_users
    hours = entries[u['id']] || [{'hours' => 0}]
    total_hours = hours.collect{|h| h['hours']}.inject(:+)  
    user = {
      :name => u['email'].split('@')[0],
      :hours => total_hours,
      :img => 'https://gravatar.com/avatar/' + Digest::MD5.hexdigest(u['email'])
    }
    @users.push user
  end
  
  erb :index
end

get '/user/:name' do

  entries  = @@tick.entries(:start_date => Date.today.to_s, 
                            :end_date   => Date.today.to_s,
                            :user_email      => params[:name] + '@globalpersonals.co.uk').entries.group_by{|d| d['user_id']}
  for u in @@tick_users
    if u['email'].split('@')[0] == params[:name]
      hours = entries[u['id']] || [{'hours' => 0}]
      total_hours = hours.collect{|h| h['hours']}.inject(:+)  

      
    end   
  end
 total_hours.to_s
end
