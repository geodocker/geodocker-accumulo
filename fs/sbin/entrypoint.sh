#! /usr/bin/env bash
set -eo pipefail
source /sbin/hdfs-lib.sh

# Run in all cases
if [[ -n ${HADOOP_MASTER_ADDRESS} ]]; then
  sed -i.bak "s/{HADOOP_MASTER_ADDRESS}/${HADOOP_MASTER_ADDRESS}/g" ${HADOOP_CONF_DIR}/core-site.xml
  sed -i.bak "s/{HADOOP_MASTER_ADDRESS}/${HADOOP_MASTER_ADDRESS}/g" ${ACCUMULO_CONF_DIR}/accumulo-site.xml
fi

if [[ -n ${ACCUMULO_ZOOKEEPERS} ]]; then
  sed -i.bak "s/{ACCUMULO_ZOOKEEPERS}/${ACCUMULO_ZOOKEEPERS}/g" ${ACCUMULO_CONF_DIR}/accumulo-site.xml
fi

if [[ -n ${ACCUMULO_SECRET} ]]; then
  sed -i.bak "s/{ACCUMULO_SECRET}/${ACCUMULO_SECRET}/g" ${ACCUMULO_CONF_DIR}/accumulo-site.xml
fi

if [[ -n ${ACCUMULO_PASSWORD} ]]; then
  sed -i.bak "s/{ACCUMULO_PASSWORD}/${ACCUMULO_PASSWORD}/g" ${ACCUMULO_CONF_DIR}/accumulo-site.xml
fi

# The first argument determines this container's role in the accumulo cluster
if [ -z "$1" ]; then
  echo "Select the role for this container with the docker cmd 'master', 'monitor', 'gc', 'tracer', or 'tserver'"
  exit 1
else
  case $1 in
    "master" | "tserver" | "monitor" | "gc" | "tracer")
        wait_until_port_open ${ACCUMULO_ZOOKEEPERS} 2181
        wait_until_port_open ${HADOOP_MASTER_ADDRESS} 8020
        wait_until_hdfs_is_available

        if [[ ($1 = "master") && ($2 = "--auto-init")]]; then
          set +e
          accumulo info
          if [[ $? != 0 ]]; then
            echo "Initilizing accumulo instance ${INSTANCE_NAME} at hdfs://${HADOOP_MASTER_ADDRESS}/accumulo ..."
            hdfs dfs -mkdir -p /accumulo-classpath
            accumulo init --instance-name ${INSTANCE_NAME} --password ${ACCUMULO_PASSWORD}
          else
            echo "Found accumulo instance at hdfs://${HADOOP_MASTER_ADDRESS}/accumulo ..."
          fi
          set -e
        else
          with_backoff hdfs dfs -test -d /accumulo
          if [ $? != 0 ]; then
            echo "Accumulo not initilized before timeout. Exiting ..."
            exit 1
          fi
        fi

        exec accumulo $1 ;;
    *) exec "$@"
  esac
fi
