#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

source /sbin/hdfs-lib.sh

function wait_until_accumulo_is_available(){
  wait_until_hdfs_is_available
  with_backoff hdfs dfs -test -d /accumulo
}

function accumulo_is_available(){
  hdfs dfs -test -d /accumulo
  return $?
}

function zookeeper_is_available(){
  [[ $(nc ${ZOOKEEPERS} 2181 <<< ruok) == imok ]]
  return $?
}

function ensure_user(){
  if [ ! $(id -u $1) ]; then useradd $1; fi
}
