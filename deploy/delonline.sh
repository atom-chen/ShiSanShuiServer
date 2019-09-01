#!/bin/sh
ip=`grep Host GlobalConfig/RedisConfig.ini |awk -F'=' '{print $2}'|tr -d '\r'`
port=`grep Port GlobalConfig/RedisConfig.ini |awk -F'=' '{print $2}'|tr -d '\r'`
pass=`grep Password GlobalConfig/RedisConfig.ini |awk -F'=' '{print $2}'|tr -d '\r'`
prefix=online_

if [ "$1" != "" ]; then
	prefix=$1
fi
echo "redis-cli -h $ip -p $port -a $pass keys $prefix'*'|xargs redis-cli -h $ip -p $port -a $pass del"
redis-cli -h $ip -p $port -a $pass keys $prefix'*'|xargs redis-cli -h $ip -p $port -a $pass del
