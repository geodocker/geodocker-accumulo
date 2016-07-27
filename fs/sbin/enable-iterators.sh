#!/bin/bash

ACCUMULO_USER="root"

accumulo shell -u ${ACCUMULO_USER} -p ${ACCUMULO_PASSWORD} <<-EOF
  createnamespace geomesa
  config -s general.vfs.context.classpath.geomesa=file:///opt/geomesa/accumulo/geomesa-accumulo-distributed-runtime-${GEOMESA_VERSION}.jar
  config -ns geomesa -s table.classpath.context=geomesa
  createnamespace geowave
  config -s general.vfs.context.classpath.geowave=file:///usr/local/geowave/accumulo/geowave-accumulo.jar
  config -ns geowave -s table.classpath.context=geowave
EOF
