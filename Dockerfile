FROM quay.io/geodocker/hdfs:latest

MAINTAINER Pomadchin Grigory, daunnc@gmail.com

ENV ACCUMULO_VERSION 1.7.2
ENV ACCUMULO_HOME /opt/accumulo
ENV ACCUMULO_CONF_DIR $ACCUMULO_HOME/conf

ENV ZOOKEEPER_HOME /usr/lib/zookeeper

ENV PATH $PATH:$ACCUMULO_HOME/bin:$GEOMESA_HOME/bin

# Accumulo and Zookeeper client
RUN set -x \
  && curl http://archive.apache.org/dist/bigtop/bigtop-1.1.0/repos/centos7/bigtop.repo > /etc/yum.repos.d/bigtop.repo \
  && yum -y install zookeeper \
  && mkdir -p ${ACCUMULO_HOME} ${ACCUMULO_CONF_DIR} \
  && curl -sS -# http://apache.mirrors.pair.com/accumulo/${ACCUMULO_VERSION}/accumulo-${ACCUMULO_VERSION}-bin.tar.gz \
  | tar -xz -C ${ACCUMULO_HOME} --strip-components=1 \
  && cp ${ACCUMULO_HOME}/conf/examples/3GB/standalone/* ${ACCUMULO_CONF_DIR}/ \
  && yum install -y make gcc-c++ \
  && bash -c "${ACCUMULO_HOME}/bin/build_native_library.sh" \
  && yum -y autoremove gcc-c++
  # TODO: Clean up after build_native_library

WORKDIR "${ACCUMULO_HOME}"
COPY ./fs /
ENTRYPOINT [ "/sbin/entrypoint.sh" ]
