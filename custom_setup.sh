#!/bin/bash

cd

sudo apt-get install -y fswebcam apache2

#apache2
if [ -e /etc/apache2/sites-enabled/picture.conf ]; then
  sudo a2dissite picture
fi

if [ -e /etc/apache2/sites-available ]; then
  USER=`whoami`
  cat ./conf/picture.conf.default |
  sed -e "s/whoami/${USER}/g" > ./conf/picture.conf
  sudo cp ./conf/picture.conf /etc/apache2/sites-available
  sudo a2ensite picture
  sudo /etc/init.d/apache2 restart
fi

#picture
cp picuture/ini/scpserver.ini.default picture/ini/scpserver.ini
crontab -l >> picture/conf/cron.txt
crontab picture/conf/cron.txt
echo "cronに以下を内容を登録しました"
crontab -l

sudo crontab -l >> picture/conf/reboot.txt &&
sudo crontab picture/conf/reboot.txt
echo "rootのcronに以下を内容を登録しました"
sudo crontab -l

#File Server
echo -n " enter SEND FILE SERVER IP Adress="
read FILESERVER

echo -n " enter SEND FILE SERVER User="
read SCPUSER

echo -n " enter SEND FILE SERVER Directory="
read DIR

echo "IP Adress=${FILESERVER}"
echo "User=${SCPUSER}"
echo "Directory=${DIR}"

echo -n "Is this ok? (y/n)"
read ANSER

FLG=1
if [ ${ANSER} != "y" ]; then
  echo "Sorry,Try editing conf/scpserver.ini...."
  FLG=0
fi

if [ ${FLG} -eq 1 ]; then
  if [ ! -e picture/ini/scpserver.ini ]; then
    cp picture/ini/scpserver.ini.default picture/ini/scpserver.ini
  fi

  cat picture/ini/scpserver.ini.default |
  sed -e "s/^FILESERVER.*/FILESERVER=${FILESERVER}/g" |
  sed -e "s/^SCPUSER.*/SCPUSER=${SCPUSER}/g"          |
  sed -e "s/^DIR.*/DIR=${DIR}/g" > picture/ini/scpserver.ini

  cat picture/ini/scpserver.ini
  echo "created picture/ini/scpserver.ini"
fi

#SSH public key
if [ ! -e .ssh/id_rsa.pub ]; then
  echo "SSHキーを作成します。エンターを数回押してください。"
  ssh-keygen
fi

if [ ${FLG} -eq 1 ]; then
  if [ -e ~/.ssh/id_rsa.pub ]; then
    HOSTNAME=`hostname`
    RSA=id_rsa.pub.${HOSTNAME}
    RSAPATH=.ssh/${RSA}
    cp .ssh/id_rsa.pub ${RSAPATH}
    scp ${RSAPATH} ${SCPUSER}@${FILESERVER}:/home/${SCPUSER}/.ssh
    if [ $? -eq 0 ]; then
      echo "You may do on this PC"
      echo " ssh ${SCPUSER}@${FILESERVER}"
      echo " (enter password and after login ${FILESERVER})"
      echo " cd /home/${SCPUSER}/.ssh"
      echo " cat ${RSA} >> authorized_keys"
    else
      echo "Sorry,SCP failed..."
    fi

    rm ${RSAPATH}
  else
    echo "missing id_rsa.pub..."
    echo "You may do on this PC"
    echo "ssh-keygen"
  fi
fi

