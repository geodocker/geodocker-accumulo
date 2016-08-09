#! /usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
source /sbin/accumulo-lib.sh

ACCUMULO_SECRET=${ACCUMULO_SECRET:-DEFAULT}
INSTANCE_NAME=${INSTANCE_NAME:-accumulo}

# HDFS Configuration
template $HADOOP_CONF_DIR/core-site.xml

# Accumulo Configuration
# core-site.xml could have been volume mounted, use it as default
DEFAULT_FS=$(xmllint --xpath "//property[name='fs.defaultFS']/value/text()"  $HADOOP_CONF_DIR/core-site.xml)
INSTANCE_VOLUME=${INSTANCE_VOLUME:-$DEFAULT_FS/$INSTANCE_NAME}
template $ACCUMULO_CONF_DIR/accumulo-site.xml

# The first argument determines this container's role in the accumulo cluster
ROLE=${1:-}
if [ -z $ROLE ]; then
  echo "Select the role for this container with the docker cmd 'master', 'monitor', 'gc', 'tracer', or 'tserver'"
  exit 1
else
  case $ROLE in
    "master" | "tserver" | "monitor" | "gc" | "tracer")
      ATTEMPTS=7 # ~2 min before timeout failure
      with_backoff zookeeper_is_available || exit 1
      wait_until_hdfs_is_available || exit 1

      USER=${USER:-root}
      ensure_user $USER
      echo "Running as $USER"

      # Initialize Accumulo if required
      if [[ ($ROLE = "master") && (${2:-} = "--auto-init")]]; then
        set +e
        accumulo info &> /dev/null
        if [[ $? != 0 ]]; then
          echo "Initializing accumulo instance ${INSTANCE_NAME} at hdfs://${HADOOP_MASTER_ADDRESS}/accumulo ..."
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
