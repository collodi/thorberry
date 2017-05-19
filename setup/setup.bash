#!/bin/bash

# check sudo
if [[ $EUID -ne 0 ]]; then
	printf "Run as root."
	exit 1
fi

# check internet
wget -q --tries=3 --timeout=3 --spider http://google.com
if [[ $? -ne 0 ]]; then
	printf "No Internet."
	exit 1
fi

# update & upgrade
apt update && apt upgrade
if [[ $? -ne 0 ]]; then
	printf "Linux update failed."
	exit 1
fi

SPI_CONFIG='/boot/config.txt'
NGINX_DIR='/etc/nginx'
SETUP_DIR="$(dirname $0)"

cd "$SETUP_DIR"

# enable spi
dtparam spi=on
printf "\ndtparam=spi=on\n" >> "$SPI_CONFIG"

# pi in gpio, spi
usermod -aG gpio,spi pi

# install git, nodejs, nginx
apt-get install -y git nodejs nginx

# set up nginx
cp  nginx.example "$NGINX_DIR/sites-available/thorberry"
ln -s "$NGINX_DIR/sites-available/thorberry" "$NGINX_DIR/sites-enabled/thorberry"
## nginx: disable default server on 80
if [ -f /etc/nginx/sites-enabled/default ]; then
	rm /etc/nginx/sites-enabled/default
fi

cd "$SETUP_DIR"

# su to pi
sudo -u pi -s /bin/bash << 'eof'

THORBERRY_GIT='https://github.com/collodi/thorberry.git'
THORBERRY_RUBY_VERSION='2.4.0'
SETUP_DIR="$(pwd)"

# install rvm
\curl -sSL https://get.rvm.io | bash -s stable
. "$HOME/.bash_profile"
. "$HOME/.bashrc"

# install ruby
rvm install "$THORBERRY_RUBY_VERSION"
rvm use "$THORBERRY_RUBY_VERSION" --default
. "$HOME/.bash_profile"
. "$HOME/.bashrc"

# install bundle, rails
gem install bundle rails

# git clone thorberry
cd "$HOME"
git clone "$THORBERRY_GIT"
cd thorberry
bundle install
bundle exec rake db:migrate db:seed

echo "GEM_HOME $GEM_HOME"

# edit pi_piper
cd "$GEM_HOME/gems/pi_piper-"*"/lib/pi_piper/"
cp "$SETUP_DIR/libbcm2835.so" . ## replace libbcm2835.so
cp "$SETUP_DIR/bcm2835.rb" . ## replace self.export

# exit to root
eof

# set up systemd
cd "$SETUP_DIR"
cp systemd.example "/etc/systemd/system/thorberry.service"
systemctl enable thorberry
systemctl enable nginx
