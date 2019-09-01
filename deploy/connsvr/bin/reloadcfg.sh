#!/bin/sh

FRAME_PIDS=`ps ux | grep connsvr | grep -v grep | grep -v gdb | awk '{print $2}'`

echo "Notify process ($FRAME_PIDS) to refresh config..."

for _PID in $FRAME_PIDS
do
        kill -s USR1 $_PID
done

echo "connsvr refreshed OK"
