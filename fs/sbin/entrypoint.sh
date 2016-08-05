#! /usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
source /sbin/hdfs-lib.sh
source /sbin/accumulo-lib.sh

ACCUMULO_SECRET=${ACCUMULO_SECRET:-DEFAULT}
INSTANCE_NAME=${INSTANCE_NAME:-accumulo}

# Run in all cases
sed -i.bak "s/{HADOOP_MASTER_ADDRESS}/${HADOOP_MASTER_ADDRESS}/g" ${HADOOP_CONF_DIR}/core-site.xml
sed -i.bak \
  -e "s/{HADOOP_MASTER_ADDRESS}/${HADOOP_MASTER_ADDRESS}/g" \
  -e "s/{ZOOKEEPERS}/${ZOOKEEPERS}/g" \
  -e "s/{ACCUMULO_SECRET}/${ACCUMULO_SECRET}/g" \
  ${ACCUMULO_CONF_DIR}/accumulo-site.xml

# The first argument determines this container's role in the accumulo cluster
ROLE=${1:-}
echo "Executing with role: $ROLE"
if [ -z $ROLE ]; then
  echo "Select the role for this container with the docker cmd 'master', 'monitor', 'gc', 'tracer', or 'tserver'"
  exit 1
else
  case $ROLE in
    "master" | "tserver" | "monitor" | "gc" | "tracer")
      ATTEMPTS=7 # ~2 min before timeout failure
      echo "Checking zookeeper availability ..."
      with_backoff zookeeper_is_available || exit 1
      echo "Zookeeper is now available ..."
      wait_until_hdfs_is_available || exit 1

      USER=${USER:-root}
      ensure_user $USER
      echo "Running as $USER"

      # Initilize Accumulo if required
      if [[ ($ROLE = "master") && (${2:-} = "--auto-init")]]; then
        set +e
        if [[ $(accumulo info) != 0 ]]; then
          echo "Initilizing accumulo instance ${INSTANCE_NAME} at hdfs://${HADOOP_MASTER_ADDRESS}/accumulo ..."
          runuser -p -u $USER hdfs -- dfs -mkdir -p /accumulo-classpath
          runuser -p -u $USER accumulo -- init --instance-name ${INSTANCE_NAME} --password ${ACCUMULO_PASSWORD}
        else
          echo "Found accumulo instance at hdfs://${HADOOP_MASTER_ADDRESS}/accumulo ..."
        fi
        set -e
      fi

      if [[ $ROLE != "master" ]]; then
        with_backoff accumulo_is_available || exit 1
      fi

      exec runuser -p -u $USER accumulo -- $ROLE ;;
    *)
      exec "$@"
  esac
fi
