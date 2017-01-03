#! /bin/bash

cd `dirname $0`

###############################################
#変数

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

if [ ! -d "$INIDIR" ]; then
  echo "error iniディレクトリがありません。処理を中止します"
  exit 1
fi

if [ ! -e "$INIDIR"/video*.ini ]; then
  echo "error カメラ設定ファイルがありません。処理を中止します。"
  exit 1
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
for vdo in `ls /dev | grep -E 'video[0-9]+$'`
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
    echo "error ${vdo}で撮影できませんでした...."
  fi

  echo "sleeping ${SLEEPTIME}sec"
  sleep ${SLEEPTIME}
done

#ファイル送信
for SCPINI in `ls ${INIDIR}/scpserver*.ini`
do
  #設定ファイル読み込み
  . ${SCPINI}

  for vdo in `ls /dev | grep -E 'video[0-9]+$'`
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
awk -F"[\/|_|\.]" '{print substr($3,4,4),substr($3,8,2),substr($3,10,2),$4}' |
sort |
uniq > public/image_list.txt
