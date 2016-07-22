#!/bin/bash

ACCUMULO_USER="root"

accumulo shell -u ${ACCUMULO_USER} -p ${ACCUMULO_PASSWORD} <<-EOF
  createnamespace geomesa
  config -s general.vfs.context.classpath.geomesa=file:/opt/geomesa/accumulo/*.jar
  config -ns geomesa -s table.classpath.context=geomesa
EOF
