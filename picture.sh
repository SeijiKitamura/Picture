#! /bin/sh

HOSTNAME="raspberry1"

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

