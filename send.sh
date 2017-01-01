#! /bin/sh

#何日前からのデータをサーバーに送信するかセット
BACKDAY=1

#PC名をセット
HOSTNAME=`hostname`

cd `dirname $0`

#ローカルの写真をセーブする場所をセット
SAVEDIR=`pwd`/img

#iniファイルのディレクトリをセット
INIDIR=`pwd`/ini

#保存場所を確認
if [ ! -d "$SAVEDIR" ]; then
  echo "error ${SAVEDIR}がありません..."
  exit 1
fi

if [ ! -d "$INIDIR" ]; then
  echo "error iniディレクトリがありません。処理を中止します"
  exit 1
fi

#SCP用iniファイル存在チェック
if ls ${INIDIR}/scpserver*.ini > /dev/null 2>&1
then
  echo "SCP送信先設定ファイル(${INIDIR}/scpserver*.iniの存在を確認しました"
else
  echo "error SCP送信先設定ファイルが存在しません。"
  exit 1
fi

#処理開始
for SCPINI in `ls ${INIDIR}/scpserver*.ini`
do
  #設定ファイル読み込み
  . ${SCPINI}

  for i in $(seq 0 ${BACKDAY});do
    HIDUKE=`date +"%Y%m%d" --date "${i} days ago"`
    TOSI=`date -d ${HIDUKE} +"%Y"`
    TUKI=`date -d ${HIDUKE} +"%m"`
    HI=`date -d ${HIDUKE} +"%d"`

    for vdo in `ls /dev| grep -E 'video[0-9]+$'`;do
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
