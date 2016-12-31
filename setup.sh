#!/bin/bash

cd

sudo apt-get install -y fswebcam apache2

#apache2
sudo cp raspberry/picture.conf /etc/apache2/sites-available
sudo a2ensite picture
sudo /etc/init.d/apache2 restart

#picture
cd
git clone git@172.16.0.13:/home/git/picture.git

#cron
cd picture
crontab cron.txt
su -c "crontab reboot.txt"

