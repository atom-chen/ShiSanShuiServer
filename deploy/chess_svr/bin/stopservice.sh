#!/bin/sh

FRAME_PIDS=`ps ux | grep chess_svr | grep -v grep | awk '{print $2}'`

echo "Notify process ($FRAME_PIDS) to stop service..."

for _PID in $FRAME_PIDS
do
        kill -s USR2 $_PID
done

echo "StopServer OK"
