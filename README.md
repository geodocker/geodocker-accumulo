# GeoDocker Accumulo

[![Build Status](https://api.travis-ci.org/geodocker/geodocker-accumulo.svg)](http://travis-ci.org/geodocker/geodocker-accumulo)
[![Docker Repository on Quay](https://quay.io/repository/geodocker/base/status "Docker Repository on Quay")](https://quay.io/repository/geodocker/accumulo)
[![Join the chat at https://gitter.im/geotrellis/geotrellis](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/geotrellis/geotrellis?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

[Apache Accumulo](https://accumulo.apache.org/) container for [GeoDocker Cluster](https://github.com/geodocker/geodocker)

# Roles
This container has three roles that can be supplied as `CMD`:

  - `master` - master instance, handles synchronization
    - `--auto-init` - initialize an accumulo instance if one is not found at `hdfs://${HADOOP_MASTER_ADDRESS}/accumulo`
  - `tserver` - tablet server, serves data
  - `monitor` - monitor instance, provides Web GUI at 50095
  - `gc` - garbage collector for accumulo tablets
  - `tracer` - trace for debugging

# Configuration

Accumulo container requires HDFS as well as Accumulo configuration. This configuration will be templated for you if you provide the required environment variables.

Additionally you have an option of volume mounting the configuration files to `/etc/hadoop/conf` to configure HDFS and `/opt/accumulo/conf` to configure Accumulo.

# Environment
  - `HADOOP_MASTER_ADDRESS` - hostname for accumulo root, required for all roles
  - `ZOOKEEPERS` - list of zookeeper instance, at least one
  - `ACCUMULO_SECRET` - secret value for inter-instance communication (default: DEFAULT)
  - `INSTANCE_NAME` - accumulo instance name (default: accumulo)
  - `ACCUMULO_PASSWORD` - root password (default: secret)
  - `INSTANCE_VOLUME` - HDFS path to accumulo instance volume, generated if not provided

`HADOOP_MASTER_ADDRESS` need not be provided if `core-site.xml` is volume mounted in `/etc/hadoop/conf` or `INSTANCE_VOLUME` is provided.

# Testing
This container should be tested with `docker-compose` and through `make test`
