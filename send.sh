#! /bin/sh

#このファイルのディレクトリへ移動
SHPATH=`which $0`
REALDIR=`dirname ${SHPATH}`
cd ${REALDIR}

#変数セット
HOSTNAME="raspberrypi1"
BACKDAY=3                 #何日前からのデータからバックアップするかをセット
SAVEDIR=`pwd`/img/DAY     #ローカル写真保存場所
FILESERVER=172.16.0.12    #ファイルサーバーアドレス
SCPUSER=kennpin1          #ファイルサーバーへのログインID
DIR=/mnt/usb2/samba/img   #ファイルサーバー上のPath

#処理開始
for i in $(seq 1 ${BACKDAY});do
 HIDUKE=`date +"%Y%m%d" --date "${i} days ago"`
 TOSI=`date -d ${HIDUKE} +"%Y"`
 TUKI=`date -d ${HIDUKE} +"%m"`
 HI=`date -d ${HIDUKE} +"%d"`
 for VDO in `ls /dev| grep video`;do
  #送信ファイル確定
  SENDFILE=${SAVEDIR}${HIDUKE}*_${VDO}.jpg

  #ファイルサーバー保存場所確定
  SCPDIR=${SCPUSER}@${FILESERVER}:${DIR}/${TOSI}/${TUKI}/${HI}/${HOSTNAME}/${VDO}

  #ファイル送信
  scp -p ${SENDFILE} ${SCPDIR} >/dev/null
 done
done
