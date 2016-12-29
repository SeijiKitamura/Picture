#! /bin/sh

#変数セット
SAVEDIR=`pwd`/img/DAY     #ローカル写真保存場所

HOSTNAME="raspberrypi1"
FILESERVER=172.16.0.12    #ファイルサーバーアドレス
SCPUSER=kennpin1          #ファイルサーバーへのログインID
DIR=/mnt/usb2/samba/img   #ファイルサーバー上のPath

HOSTNAME2="raspberry1"
FILESERVER2="172.16.0.161"
SCPUSER2="kennpin1"          #ファイルサーバーへのログインID
DIR2="/home/kennpin1/ドキュメント/RubyOnRails/spade/public/pictures"

cd `dirname $0`

#ファイル名に使用する日付をゲット
TOSI=`date +%Y`
TUKI=`date '+%m'`
HI=`date '+%d'`
JI=`date '+%H'`
FUN=`date '+%M'`
HIDUKE=${TOSI}${TUKI}${HI}${JI}${FUN}

#ローカルの写真をセーブする場所をセット
SAVEDIR=`pwd`/img

#iniファイルのディレクトリをセット
INIDIR=`pwd`/ini

#logファイルのディレクトリをセット
LOGDIR=`pwd`/log

if [ ! -d "$INIDIR" ]; then
  echo "iniディレクトリがありません。処理を中止します"
  exit 1
fi

if [ ! -e "$INIDIR"/video*.ini ]; then
  echo "カメラ設定ファイルがありません。処理を中止します。"
  exit 1
fi

#保存場所を作成
if [ ! -d "$SAVEDIR" ]; then
  mkdir $SAVEDIR
fi

#ログの保存場所を作成
if [ ! -d "$LOGDIR" ]; then
  mkdir $LOGDIR
fi

#撮影開始
for vdo in `ls /dev | grep video[0-3]`
do
  #iniファイルの存在チェック
  #なければ./ini/video_default.iniを使用
  if [ -e ${INIDIR}/${vdo}.ini ]; then
   INIFILE=${INIDIR}/${vdo}.ini
  else
   INIFILE=${INIDIR}/video_default.ini
  fi

  echo "------------------------------------------" >> log/fswebcam.log
  echo `date +"%Y-%m-%d %H:%M:%S "` "START"         >> log/fswebcam.log
  /usr/bin/fswebcam -d /dev/${vdo} -c ${INIFILE} --title ${HOSTNAME}_${vdo} --save ${SAVEDIR}/DAY${HIDUKE}_${vdo}.jpg
done

#ファイル送信
for vdo in `ls /dev | grep video[0-3]`
do
  #送信ファイル
  SENDFILE=${SAVEDIR}/DAY${HIDUKE}_${vdo}.jpg

  #ファイルサーバー保存場所確定
  SCPDIR=${SCPUSER}@${FILESERVER}:${DIR}/${TOSI}/${TUKI}/${HI}/${HOSTNAME}/${vdo}
  SCPDIR2=${SCPUSER2}@${FILESERVER2}:${DIR2}/${TOSI}/${TUKI}/${HI}/${HOSTNAME2}/${vdo}

  #ファイル送信
  if [ -e ${SENDFILE} ]; then
    scp -p ${SENDFILE} ${SCPDIR} >/dev/null
    scp -p ${SENDFILE} ${SCPDIR2} >/dev/null
  fi
done
