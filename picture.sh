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

#撮影開始
for vdo in ${video[@]}
do
  #iniファイルの存在チェック
  #なければ./ini/video_default.iniを使用
  if [ -e ${INIDIR}/${vdo}.ini ]; then
   INIFILE=${INIDIR}/${vdo}.ini
  else
   INIFILE=${INIDIR}/video_default.ini
  fi

  echo "${vdo}の撮影開始"

  /usr/bin/fswebcam -q -d /dev/${vdo} -c ${INIFILE} --title ${HOSTNAME}_${vdo} --save ${SAVEDIR}/DAY${HIDUKE}_${vdo}.jpg

  if [ $? -ne 0 ]; then
    echo "error ${vdo}の撮影ができませんでした...."
  fi

  echo "sleeping ${SLEEPTIME}sec"
  sleep ${SLEEPTIME}
done

#撮影リカバリー(3 try)
for vdo in ${video[@]}
do

  #iniファイルの存在チェック
  #なければ./ini/video_default.iniを使用
  if [ -e ${INIDIR}/${vdo}.ini ]; then
   INIFILE=${INIDIR}/${vdo}.ini
  else
   INIFILE=${INIDIR}/video_default.ini
  fi

  for ((i=0;i<3;i++))
  do
    if [ ! -e ${SAVEDIR}/DAY${HIDUKE}_${vdo}.jpg ]; then
      echo "${vdo}のリカバリー"
      sleep ${SLEEPTIME}
      echo "${vdo}の撮影開始"
      /usr/bin/fswebcam -q -d /dev/${vdo} -c ${INIFILE} --title ${HOSTNAME}_${vdo} --save ${SAVEDIR}/DAY${HIDUKE}_${vdo}.jpg
    fi
  done
done

#ファイル送信
for SCPINI in `ls ${INIDIR}/scpserver*.ini`
do
  #設定ファイル読み込み
  . ${SCPINI}

  #for vdo in `ls /dev | grep -E 'video[0-9]+$'`
  for vdo in ${video[@]}
  do
    #送信ファイル
    SENDFILE=${SAVEDIR}/DAY${HIDUKE}_${vdo}.jpg

    if [ -e ${SENDFILE} ]; then
      #ファイルサーバー保存場所確定
      SCPDIR=${SCPUSER}@${FILESERVER}:${DIR}/${TOSI}/${TUKI}/${HI}/${HOSTNAME}/${vdo}

      #ファイル送信
      scp -p ${SENDFILE} ${SCPDIR} 2>&1

      if [ $? -eq 0 ]; then
        echo "success scp ${SENDFILE} ${SCPDIR}"
      else
        echo "error scp ${SENDFILE} ${SCPDIR}"
      fi
    fi
  done
done

#写真リスト更新
find ${SAVEDIR} -maxdepth 1 -type f -name "DAY*.jpg" |
xargs -I{} basename {} |
awk -F"[\/|\.|_]" '{print substr($1,4,4),substr($1,8,2),substr($1,10,2),$2}' |
sort |
uniq > public/image_list.txt

exit 0
