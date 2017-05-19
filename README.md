# thorberry
Lightning watch system using 
 - RPi
 - Ruby on Rails
 - [Thorguard](http://thorguard.com/)

## Setting Up thorberry On RPi
 - connect to the Internet
 - [enable spi](https://www.raspberrypi.org/documentation/hardware/raspberrypi/spi/README.md)
 - make sure the user `pi` is in groups `gpio` and `spi`
 - make sure `git`, `nodejs`, and `ruby` (>= 2.x) are installed [Ruby Installation by Ray Hightower](http://rayhightower.com/blog/2012/12/03/ruby-on-raspberry-pi/)
 - install `bundle` and `rails` gems
 - git clone thorberry
 - run `bundle install` and `bundle exec rake db:migrate db:seed` inside the cloned directory
 - [install & set up Nginx](#nginx-setup)
 - [edit pi_piper](#export-ebusy)
 
## Setting Up Nginx <a name="nginx-setup"></a>
An example configuration file looks like this:

    upstream thorberry {
        server localhost:3000;
    }

    server {
        listen 80 default_server;
        server_name _;

        keepalive_timeout 5;

        root /home/pi/thorberry/public;
        access_log /home/pi/thorberry/log/nginx.access.log;
        error_log /home/pi/thorberry/log/nginx.error.log info;

        location / {
	           proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header Host $http_host;
            
            if (-f $request_filename) {
                break;
            }
            
            proxy_pass http://thorberry;
	       }
    }

## pi_piper "/dev/mem: Permission denied" fix
The solution is to replace `libbcm2835.so` in `/path/to/gems/pi_piper-2.0.0/lib/pi_piper/`.
The replacement file is provided in the repo.

## pi_piper "Permission Denied @ rb_sysopen" workaround
The problem turned out to be some kind of a race condition between the script and the file creation.
It seemed to have only happened to me, but I was getting the error every single time.
Right after the GPIO pins are exported, the files in the newly created directory are not accessible by the `gpio` group.

For now, I applied a cheap workaround.

    # In /path/to/gems/pi_piper-2.0.0/lib/pi_piper/bcm2835.rb
    
    def self.export(pin)
      File.write('/sys/class/gpio/export', pin)
      sleep 0.1 # to prevent race condition that gives EACCESS
      @pins << pin unless @pins.include?(pin)
    end
    
## pi_piper "/sys/class/gpio/export EBUSY" workaround
The problem arises because I cannot think of a good way to keep the GPIO pin instances alive.
When the PiPiper::Pin.new is called on a pin that is already exported, the EBUSY error occurs.

My workaround is to tweak the pi_piper's export method. The final export method is shown below. 

    # In /path/to/gems/pi_piper-2.0.0/lib/pi_piper/bcm2835.rb
    
    def self.export(pin)
      return if @pins.include?(pin)
      
      File.write('/sys/class/gpio/export', pin)
      sleep 0.1 # to prevent race condition that gives EACCESS
      @pins << pin
    end
Keep in mind that this is a workaround, not a fix.

## Default Logins
Administrator: `thor`/`sonofodin`
Guest: `loki`/`notsonofodin`

This information can be changed in `db/seeds.rb'.
