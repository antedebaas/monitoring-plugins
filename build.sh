#!/usr/bin/env bash

export PLUGINS="check_disk,check_dns,check_http,check_load,check_log,check_ntp,check_ntp_peer,check_ntp_time,check_ping,check_procs,check_smtp,check_snmp,check_ssh,check_swap,check_tcp,check_time,check_users,utils.sh"
export SENSU_GO_ASSET_VERSION=$(git describe --abbrev=0 --tags)

mkdir assets/
for PLATFORM in alpine amazon2 amazonlinux2022 debian10 debian11 centos7 centos8 ubuntu1804 ubuntu2004 ubuntu2204 raspberrypi64;
do
  if [[ ${PLATFORM} == "raspberrypi64"  ]]; then
    export ARCH="arm64"
  else
    export ARCH="amd64"
  fi;
  export SENSU_GO_ASSET_FILENAME="monitoring-plugins-${PLATFORM}_${SENSU_GO_ASSET_VERSION}_linux_${ARCH}.tar.gz"
  docker build --no-cache --rm --build-arg "PLUGINS=$PLUGINS" --build-arg "SENSU_GO_ASSET_VERSION=$SENSU_GO_ASSET_VERSION" -t monitoring-plugins-${PLATFORM}:$SENSU_GO_ASSET_VERSION -f Dockerfile.${PLATFORM} .
  docker cp -L $(docker create --rm monitoring-plugins-${PLATFORM}:$SENSU_GO_ASSET_VERSION true):/$SENSU_GO_ASSET_FILENAME ./assets/
done;

cd assets/
export SENSU_GO_CHECKSUMS_FILENAME="monitoring-plugins_${SENSU_GO_ASSET_VERSION}_sha512-checksums.txt"
if [[ $(which sha512sum) ]]; then
  sha512sum ./*.tar.gz > $SENSU_GO_CHECKSUMS_FILENAME;
elif [[ $(which shasum) ]]; then
  shasum -a 512 *.tar.gz > $SENSU_GO_CHECKSUMS_FILENAME;
fi;