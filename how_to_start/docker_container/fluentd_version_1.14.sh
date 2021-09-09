#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

#------------------------

app=fluentd
version=v1.14
log_dir=/opt/$app/data

#------------------------

if [ "$1" == "delete" ] || [ "$1" == "drop" ] || [ "$1" == "uninstall" ] || [ "$1" == "remove" ]; then
   rm -rf $log_dir > /dev/null 2>&1
   docker rm -f $app > /dev/null 2>&1
   docker rmi fluent/fluentd:$version > /dev/null 2>&1
   echo ""
   echo "Fluentd was removed"
   echo ""
   exit 0
fi

#------------------------

mkdir -p $log_dir
chmod 777 $log_dir

#------------------------

docker run -d --name $app -p 24224:24224 -p 24224:24224/udp -v $log_dir:/fluentd/log fluent/fluentd:$version

#------------------------

sleep 5

docker ps -a | grep $app

if [ "$(docker ps -a | grep $app | grep xit > /dev/null 2>&1; echo $?)" -eq "0" ]; then docker logs -n 30 $app; docker rm -f $app; exit 1; fi

docker logs $app

echo ""
echo "Fluentd started successfully =)"
echo ""
