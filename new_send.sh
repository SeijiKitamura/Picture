#! /bin/bash

#######################################################
# 引数
#
# 開始日(YYYYMMDD),終了日(YYYYMMDD)
# 
# カメラ側でディレクトリを作成し、rsyncでファイルを
# サーバーに送信している。こうすることで、サーバー側で # 受け取るディレクトリを作成しなくて済む。
#######################################################

# 送信先フォルダ 
SERVER_DIR="172.16.0.16:/home/kennpin1/picture/img"

#何日前からのデータをサーバーに送信するかセット
BACKDAY=30

cd `dirname $0`

# 引数チェック
if [ $# -eq 2 ]; then
  KAISI=$1
  OWARI=$2
  if [ ${OWARI} -lt ${KAISI} ]; then
    echo "開始日と終了日を確認してください"
    exit 1
  fi
fi

if [ $# -eq 1 ]; then
  KAISI=$1
  OWARI=${KAISI}
fi

if [ $# -eq 0 ]; then
  KAISI=`date +"%Y%m%d" --date "${BACKDAY} days ago"`
  OWARI=`date +"%Y%m%d"`
fi

#PC名をセット
HOSTNAME=`hostname`

#ローカルの写真が保存してある場所をセット
SAVEDIR=`pwd`/public/img

#保存場所を確認
if [ ! -d "$SAVEDIR" ]; then
  echo "error ${SAVEDIR}がありません..."
  exit 1
else
   echo "保存場所(${SAVEDIR})を確認しました"
fi

if [ $KAISI -eq $OWARI ]; then
  echo "${KAISI}の画像を送信します。"
else
  echo "${KAISI}から${OWARI}の画像を送信します。"
fi

NOWDAY=${KAISI}
while :; do
  NEN=${NOWDAY:0:4}
  TUKI=${NOWDAY:4:2}
  HI=${NOWDAY:6:2}

  # ファイル存在確認
  ls ${SAVEDIR}/DAY${NOWDAY}*.jpg > /dev/null 2>&1

  if [ $? -eq 0 ]; then
    echo "${NOWDAY}の画像を送信中"
    # videoごとにディレクトリを作成
    find ${SAVEDIR} -maxdepth 1 -type f -name "DAY${NOWDAY}*.jpg" |  
    awk 'BEGIN{FS="[._]";OFS="";}{print $2}'                      |
    sort                                                          |
    uniq                                                          |
    xargs -i mkdir -p ${SAVEDIR}/${NEN}/${TUKI}/${HI}/${HOSTNAME}/{}

    # 作成したディレクトリにファイルをコピー
    find ${SAVEDIR} -maxdepth 1 -type f -name "DAY${NOWDAY}*.jpg" |
    awk -v SAVEDIR=${SAVEDIR} -v HOSTNAME=${HOSTNAME} 'BEGIN{FS="[./_]";OFS=" ";}
         {
           SEND_DIR=SAVEDIR"/"substr($7,4,4)"/"substr($7,8,2)"/"substr($7,10,2)"/"HOSTNAME"/"$8;
           system("cp "$0" "SEND_DIR"");
        }'

    # 年またぎに対応するためここで送信している
    rsync -av ${SAVEDIR}/${NEN} ${SERVER_DIR}

    # サーバーにコピーした画像は削除する
    if [ $? -eq 0 ]; then
      echo "日付 ${NOWDAY}の写真を削除します"
      find ${SAVEDIR} -maxdepth 1 -type f -name "DAY${NOWDAY}*.jpg" -delete
      echo "日付 ${NOWDAY}の写真を削除しました"
    fi

    # 作業ディレクトリ削除
    rm -rf ${SAVEDIR}/${NEN}
    echo "${NOWDAY}の画像を送信しました"
  else
    echo "${NOWDAY}の画像は存在しません"
  fi

  NOWDAY=`date +"%Y%m%d" --date "${NOWDAY} 1 day"`
  if [ ${NOWDAY} -gt ${OWARI} ]; then
    break
  fi
done
