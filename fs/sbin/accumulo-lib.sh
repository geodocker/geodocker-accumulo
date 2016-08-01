#!/usr/bin/env bash

source /sbin/hdfs-lib.sh

wait_until_accumulo_is_available(){
  wait_until_hdfs_is_available
  with_backoff hdfs dfs -test -d /accumulo
}

accumulo_is_available(){
  hdfs dfs -test -d /accumulo
  return $?
}

zookeeper_is_available(){
  [ $(nc ${ZOOKEEPERS} 2181 <<< ruok) == imok ]
  return $?
}

ensure_user() {
  if [ ! $(id -u $1) ]; then useradd $1; fi
}
