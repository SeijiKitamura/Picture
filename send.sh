#! /bin/bash

###############################################
#変数

#接続カメラ
#video=("video0" "video1" "video2")

#何日前からのデータをサーバーに送信するかセット
BACKDAY=3

###############################################

cd `dirname $0`

#PC名をセット
HOSTNAME=`hostname`

#ローカルの写真をセーブする場所をセット
SAVEDIR=`pwd`/public/img

#iniファイルのディレクトリをセット
INIDIR=`pwd`/ini

#保存場所を確認
if [ ! -d "$SAVEDIR" ]; then
  echo "error ${SAVEDIR}がありません..."
  exit 1
else
   echo "保存場所(${SAVEDIR})を確認しました"
fi

#設定ディレクトリ存在チェック
if [ ! -d "$INIDIR" ]; then
  echo "error iniディレクトリがありません。処理を中止します"
  exit 1
else
  echo "iniディレクトリ存在確認しました"
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

#ファイル送信開始
for SCPINI in `ls ${INIDIR}/scpserver*.ini`
do
  #設定ファイル読み込み
  . ${SCPINI}

  for i in $(seq 0 ${BACKDAY});do
    HIDUKE=`date +"%Y%m%d" --date "${i} days ago"`
    TOSI=`date -d ${HIDUKE} +"%Y"`
    TUKI=`date -d ${HIDUKE} +"%m"`
    HI=`date -d ${HIDUKE} +"%d"`

    for vdo in ${video[@]}
    do
      #送信ファイル確定
      SENDFILE="DAY${HIDUKE}*_${vdo}.jpg"

      #ファイルサーバー保存場所確定
      SCPDIR=${SCPUSER}@${FILESERVER}:${DIR}/${TOSI}/${TUKI}/${HI}/${HOSTNAME}/${vdo}

      #ファイル送信
      echo "ファイル送信開始 ${SCPDIR}"
      find ${SAVEDIR} -maxdepth 1 -type f -name "${SENDFILE}" | xargs -I{} scp -p {} ${SCPDIR} 2>&1
    done
  done
done

#古い画像を削除
HIDUKE=`date +"%Y%m%d" --date "${BACKDAY} days ago"`
echo "日付 ${HIDUKE}の写真を削除します"
find ${SAVEDIR} -maxdepth 1 -type f -name "DAY${HIDUKE}*.jpg" -delete
echo "日付 ${HIDUKE}の写真を削除しました"

#写真リスト更新
find ${SAVEDIR} -maxdepth 1 -type f -name "DAY*.jpg" |
xargs -I{} basename {} |
awk -F"[\/|\.|_]" '{print substr($1,4,4),substr($1,8,2),substr($1,10,2),$2}' |
sort |
uniq > public/image_list.txt

exit 0
