#!/bin/bash

cd `dirname $0`

###############################################
#変数

#1台のPCに接続する最大カメラ台数(0から始まる)
MAX_VIDEO=10

#Webカメラのデバイス名(/devに依存)
DEV="video"

#カメラサーバーリスト
CAMERA_LIST=`pwd`/"camera_list.txt"

###############################################

TOSI=`date +%Y`
TUKI=`date '+%m'`
HI=`date '+%d'`
DIR=${TOSI}/${TUKI}/${HI}

if [ ! -e ${CAMERA_LIST} ]; then
  echo "${CAMERA_LIST}がありません...."
  exit 1
fi

while read SERVER; do
  for VIDEO in $(seq 0 $MAX_VIDEO); do
    DIRPATH=`pwd`/${SERVER}/${DIR}/${DEV}${VIDEO}
    if [ ! -e ${DIRPATH} ]; then
      mkdir -p ${DIRPATH}
      if [ $? -eq 0 ]; then
        echo "success ${DIRPATH}を作成しました"
      else
        echo "error ${DIRPATH}を作成に失敗しました"
      fi
    fi
  done
done < ${CAMERA_LIST}
