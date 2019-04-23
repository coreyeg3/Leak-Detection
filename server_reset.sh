#!/bin/bash
# Run this program as sudo


 
fuser -k 8086/tcp
fuser -k 3000/tcp

docker start influxdb #run --detach --volume=/var/influxdb:/data -p 8086:8086 --name influxdb hypriot/rpi-influxdb
docker start grafana #--detach -i -p 3000:3000 --name grafana fg2it/grafana-armhf:v5.0.4

