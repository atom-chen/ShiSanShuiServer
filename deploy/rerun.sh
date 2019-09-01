#!/bin/bash

root_dir=$( cd $( dirname ${BASH_SOURCE[0]} ) && pwd )

cd $root_dir

ulimit -c 99999999999
ulimit -n 999999

echo "MUST DO sysctl -p BEFORE !!! 1=$1, 2=$2";

need_start=1
if [ "$1" == "stop" ]; then
	need_start=0
elif [ "$1" != "" ]; then
	port1=80${1}1
	port2=80${1}2
	echo "prot=$port1";
	for f in `find . -name "ListenConfig.ini" -o -name "ConnSvr_Out.ini"`; do
		sed -i "s/80[0-9]1/$port1/g" $f
		sed -i "s/80[0-9]2/$port2/g" $f
	done
	idx=0
	for f in `find . -name "BootConfig.ini" -o -name "LanSvr.ini"`; do
		for p in 1 2 3 4 5 6 7 8 9; do
			port=${p}0${1}1
			sed -i "s/${p}0[0-9]1/$port/g" $f
		done
	done	
fi

if [ "$2" != "" ]; then
	sed -i "s/nPlayerNum = [0-9]/nPlayerNum = $2/g" ./chess_svr/script_mj/config/game_cfg_zhengzhou.lua
	# sed -i "s/PLAYER_NUMBER               = [0-9]/PLAYER_NUMBER               = $2/g" ./chess_svr/script_mj/core/core_define.lua
fi

# 当前目录下搜索exe
for svr in connsvr chess_svr online_svr event_svr ecs_svr; do
	cd $root_dir;
	exe=$(find . -name "${svr}.run*")	
	if [ "$exe" == "" -o ${#exe[@]} -lt 1 ]; then
		echo "SERVER $svr NO BIN FILE. COMPILE FAILLLLLLLLLLLLLLLLLLLLLLLL. exe count=${#exe[@]}";
		continue;
	fi

	pid=$(ps xf|grep ${svr}.run|grep -v grep|awk '{print $1}');
	echo "EXE ${svr}.run: pid count=${#pid}";
	
	# 若这个exe是在当前目录下,全杀掉
	for onepid in $pid; do
		is_pwd=$(ls -l /proc/${onepid}/cwd |awk '{print $11}'|grep $root_dir/);
		if [ "$is_pwd" != "" ]; then
			echo "KILL ${svr}, thepid=$onepid, thecwd=$root_dir/";
			kill -USR2 $onepid;
			sleep 1;
		else
			echo "SKIP ${svr}, thepid=$onepid, thecwd not current."
		fi
	done

	if [ $need_start -eq 1 ]; then
		for oneexe in $exe; do
			echo "START $oneexe"
			$oneexe
		done
	fi
done


