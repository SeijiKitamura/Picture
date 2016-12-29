#! /bin/sh

#変数セット
BACKDAY=3                 #何日前からのデータをサーバーに送信するかセット
SAVEDIR=`pwd`/img/DAY     #ローカル写真保存場所

HOSTNAME="raspberrypi1"
FILESERVER=172.16.0.12    #ファイルサーバーアドレス
SCPUSER=kennpin1          #ファイルサーバーへのログインID
DIR=/mnt/usb2/samba/img   #ファイルサーバー上のPath

HOSTNAME2="raspberry1"
FILESERVER2="172.16.0.161"
SCPUSER2="kennpin1"          #ファイルサーバーへのログインID
DIR2="/home/kennpin1/ドキュメント/RubyOnRails/spade/public/pictures"

#画像ディレクトリへ移動
SHPATH=`which $0`
REALDIR=`dirname ${SHPATH}`
cd ${REALDIR}/img

#処理開始
for i in $(seq 0 ${BACKDAY});do
  HIDUKE=`date +"%Y%m%d" --date "${i} days ago"`
  TOSI=`date -d ${HIDUKE} +"%Y"`
  TUKI=`date -d ${HIDUKE} +"%m"`
  HI=`date -d ${HIDUKE} +"%d"`
  for VDO in `ls /dev| grep video[0-3]`;do
   #送信ファイル確定
   SENDFILE="DAY${HIDUKE}*_${VDO}.jpg"

   #ファイルサーバー保存場所確定
   SCPDIR=${SCPUSER}@${FILESERVER}:${DIR}/${TOSI}/${TUKI}/${HI}/${HOSTNAME}/${VDO}
   SCPDIR2=${SCPUSER2}@${FILESERVER2}:${DIR2}/${TOSI}/${TUKI}/${HI}/${HOSTNAME2}/${VDO}

   #ファイル送信
   find . -maxdepth 1 -type f -name "${SENDFILE}" | xargs -I{} scp -p {} ${SCPDIR} > /dev/null

   #ファイル送信
   find . -maxdepth 1 -type f -name "${SENDFILE}" | xargs -I{} scp -p {} ${SCPDIR2} > /dev/null
  done
done

#古い画像を削除
HIDUKE=`date +"%Y%m%d" --date "${BACKDAY} days ago"`
find . -maxdepth 1 -type f -name "DAY${HIDUKE}*.jpg" -delete
