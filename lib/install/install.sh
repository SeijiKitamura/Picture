#!/bin/bash

cd

sudo apt-get install -y vim fswebcam apache2

#apache
sudo cp picture.conf /etc/apache2/sites-available
sudo a2ensite picture
sudo /etc/init.d/apache2 restart

#vim
cp lib/install/.vimrc /home/pi/
echo "alias vi='/usr/bin/vim'" >> /home/pi/.bashrc
source .bashrc
cd
mkdir -p .vim/bundle

