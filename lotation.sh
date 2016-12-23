#!/bin/bash

cd `dirname $0;pwd`

if [ -e log/fswebcam.log.7 ]; then
  rm log/fswebcam.log.7
fi

if [ -e log/fswebcam.log.6 ]; then
  mv log/fswebcam.log.6 log/fswebcam.log.7
fi

if [ -e log/fswebcam.log.5 ]; then
  mv log/fswebcam.log.5 log/fswebcam.log.6
fi

if [ -e log/fswebcam.log.4 ]; then
  mv log/fswebcam.log.4 log/fswebcam.log.5
fi

if [ -e log/fswebcam.log.3 ]; then
  mv log/fswebcam.log.3 log/fswebcam.log.4
fi

if [ -e log/fswebcam.log.2 ]; then
  mv log/fswebcam.log.2 log/fswebcam.log.3
fi

if [ -e log/fswebcam.log.1 ]; then
  mv log/fswebcam.log.1 log/fswebcam.log.2
fi

if [ -e log/fswebcam.log ]; then
  mv log/fswebcam.log log/fswebcam.log.1
fi
