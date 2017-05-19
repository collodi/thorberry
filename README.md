# thorberry
Lightning watch system using 
 - RPi
 - Ruby on Rails
 - [Thorguard](http://thorguard.com/)
 - [pi_piper gem](https://github.com/jwhitehorn/pi_piper)
 - [piface gem](https://github.com/blakejakopovic/piface)

## Setting Up thorberry On RPi
 - connect to the Internet
 - `sudo apt-get update && sudo apt-get upgrade` 
 - [enable spi](https://www.raspberrypi.org/documentation/hardware/raspberrypi/spi/README.md)
 - make sure the user `pi` is in groups `gpio` and `spi`
 - install `git`, `nodejs`, `nginx`, and `ruby` (>= 2.x) [(Ruby With RVM)](https://rvm.io/)
 - install `bundle` and `rails` gems
 - git clone thorberry
 - run `bundle install` and `bundle exec rake db:migrate db:seed` inside the cloned directory
 - [edit pi_piper](#export-ebusy)
 - [install & set up Nginx](#nginx-setup)
 - [set up systemd](#systemd-setup)
 
<a name="nginx-setup"></a>
## Setting Up Nginx
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
You will have to disable the default server on 80.

## pi_piper "/dev/mem: Permission denied" fix
The solution is to replace `libbcm2835.so` in `/path/to/gems/pi_piper-2.0.0/lib/pi_piper/`.
The replacement file is provided in `setup/`.

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
    
<a name="export-ebusy"></a>
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

## piface gem output pin number
piface's README says that the relays can be accessed with pin 1 and 2.
The correct pin numbers are 0 and 1. So the output pin numbers are from 0 to 7.

<a name="systemd-setup"></a>
## Setting Up Systemd
Here is an example systemd file.

    # /etc/systemd/system/thorberry.service
    
    [Unit]
    Description=thorberry
    Requires=network.target

    [Service]
    Type=simple
    User=pi
    WorkingDirectory=/home/pi/thorberry
    ExecStart=/bin/bash -lc 'bundle exec rails server'
    Restart=always

    [Install]
    WantedBy=multi-user.target
After setting up Nginx, run `systemctl enable nginx thorberry`.

## Default Logins
Administrator: `thor` / `sonofodin`  
Guest: `loki` / `notsonofodin`

This information can be changed in `db/seeds.rb`.
