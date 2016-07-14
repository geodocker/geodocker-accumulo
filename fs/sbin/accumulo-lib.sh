#!/usr/bin/env bash

source /sbin/hdfs-lib.sh

wait_until_accumulo_is_available(){
  wait_until_hdfs_is_available
  with_backoff hdfs dfs -test -d /accumulo
}
