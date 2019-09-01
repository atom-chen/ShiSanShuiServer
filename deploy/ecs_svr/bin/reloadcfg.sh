#!/bin/sh

FRAME_PIDS=`ps ux | grep ecs_svr | grep -v grep | grep -v gdb | awk '{print $2}'`

echo "Notify process ($FRAME_PIDS) to refresh config..."

for _PID in $FRAME_PIDS
do
        kill -s USR1 $_PID
done

echo "Config refreshed OK"
