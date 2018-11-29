#! /bin/bash

cd `dirname $0`


##############################################
#変数

#接続カメラ
#video=("video0" "video1" "video2")

#撮影間隔をセット(秒)
SLEEPTIME=3

#PC名をセット
HOSTNAME=`hostname`

#iniファイルのディレクトリをセット
INIDIR=`pwd`/ini

#ローカル写真保存場所
SAVEDIR=`pwd`/public/img

###############################################

#保存場所を作成
if [ ! -d "$SAVEDIR" ]; then
  mkdir -p $SAVEDIR
  touch ${SAVEDIR}/.gitkeep
fi

#設定ディレクトリ存在チェック
if [ ! -d "$INIDIR" ]; then
  echo "error iniディレクトリがありません。処理を中止します"
  exit 1
else
  echo "iniディレクトリ存在確認しました"
fi

#設定ファイル存在チェック
if [ ! -e "$INIDIR"/video*.ini ]; then
  echo "error カメラ設定ファイルがありません。処理を中止します。"
  exit 1
else
   echo "カメラ設定ファイル確認しました"
fi

#カメラ台数設定ファイルチェック
if [ ! -e "$INIDIR"/device.ini ]; then
  echo "error カメラ台数ファイルがありません。処理を中止します。"
  exit 1
else
  . ${INIDIR}/device.ini 
  echo "device.ini確認しました(${video[@]})"
fi

#SCP用iniファイル存在チェック
if ls ${INIDIR}/scpserver*.ini > /dev/null 2>&1
then
  echo "SCP送信先設定ファイル(${INIDIR}/scpserver*.iniの存在を確認しました"
else
  echo "SCP送信先設定ファイルが存在しません。"
fi

#ファイル名に使用する日付をゲット
TOSI=`date +%Y`
TUKI=`date '+%m'`
HI=`date '+%d'`
JI=`date '+%H'`
FUN=`date '+%M'`
HIDUKE=${TOSI}${TUKI}${HI}${JI}${FUN}

#撮影開始(5 try)
for vdo in ${video[@]}
do

  #iniファイルの存在チェック
  #なければ./ini/video_default.iniを使用
  if [ -e ${INIDIR}/${vdo}.ini ]; then
   INIFILE=${INIDIR}/${vdo}.ini
  else
   INIFILE=${INIDIR}/video_default.ini
  fi

  for ((i=1;i<5;i++))
  do
    if [ ! -e ${SAVEDIR}/DAY${HIDUKE}_${vdo}.jpg ]; then
      sleep ${SLEEPTIME}
      echo "${vdo}の撮影 (${i}回目)"
      /usr/bin/fswebcam -q -d /dev/${vdo} -c ${INIFILE} --title ${HOSTNAME}_${vdo} --save ${SAVEDIR}/DAY${HIDUKE}_${vdo}.jpg
    fi
  done

  if [ ! -e ${SAVEDIR}/DAY${HIDUKE}_${vdo}.jpg ]; then
    echo "error ${HIDUKE} ${vdo} 撮影失敗"
  else
    echo "success ${HIDUKE} ${vdo} 撮影成功"
  fi
done

#ファイル送信(当日のみ)
/bin/bash ./new_send.sh ${TOSI}${TUKI}${HI}
exit 0
