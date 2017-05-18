# thorberry 2
lightning watch system using RPi and Ruby on Rails

## setting up thorberry on a RPi
 - connect to the Internet
 - [enable spi](https://www.raspberrypi.org/documentation/hardware/raspberrypi/spi/README.md)
 - make sure the user `pi` is in groups `gpio` and `spi`
 - make sure `git` and `ruby` (>= 2.x) are installed [Ruby Installation by Ray Hightower](http://rayhightower.com/blog/2012/12/03/ruby-on-raspberry-pi/)
 - install `bundle` and `rails` gems
 - git clone thorberry
 - run `bundle install`
 - [install & set up Nginx](#nginx-setup)
 
## setting up Nginx <a name="nginx-setup"></a>
