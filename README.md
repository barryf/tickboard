# Tickboard

Displays a red/green dashboard of who in your team has completed their 7.5 hours of time today on Tick. Useful for screens mounted around your development team to help remind them to complete their time tracking before heading home.

Much of the Tick querying code was taken from [Tim Blair](http://tim.bla.ir/)'s Tick notification project (currently private).

## Usage

    $ export TICKBOARD_USERNAME=my_tick_email@email.com
    $ export TICKBOARD_PASSWORD=my_tick_password
	$ ruby tickboard.rb

You may also wish to add any accounts you wish to exclude (e.g. accounting users) to the ignore list in `config.yml`

-- [Barry Frost](http://barryfrost.com/)