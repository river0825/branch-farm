#!/bin/bash

export CODE_FARM_ROOT=/opt/branch_farm
docker ps -a | grep docker | awk -F " " '{system("docker rm -f "$1)}'
killall openresty; /opt/openresty/bin/openresty -c ${CODE_FARM_ROOT}/conf/nginx.conf
