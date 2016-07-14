FROM quay.io/geodocker/hdfs:latest

MAINTAINER Pomadchin Grigory, daunnc@gmail.com

ENV ACCUMULO_VERSION 1.7.2
ENV ACCUMULO_HOME /opt/accumulo
ENV ACCUMULO_CONF_DIR $ACCUMULO_HOME/conf
ENV PATH $PATH:$ACCUMULO_HOME/bin
ENV ZOOKEEPER_VERSION 3.4.8
ENV ZOOKEEPER_HOME /opt/zookeeper

RUN set -x \
  && mkdir -p ${ACCUMULO_HOME} ${ACCUMULO_CONF_DIR} \
  && curl -sS -# http://apache.mirrors.pair.com/accumulo/${ACCUMULO_VERSION}/accumulo-${ACCUMULO_VERSION}-bin.tar.gz \
  | tar -xz -C ${ACCUMULO_HOME} --strip-components=1 \
  && cp ${ACCUMULO_HOME}/conf/examples/3GB/standalone/* ${ACCUMULO_CONF_DIR}/

RUN set -x \
  && mkdir -p ${ZOOKEEPER_HOME} \
  && curl -sS -# http://apache.mirrors.pair.com/zookeeper/zookeeper-${ZOOKEEPER_VERSION}/zookeeper-${ZOOKEEPER_VERSION}.tar.gz \
  | tar -xz -C ${ZOOKEEPER_HOME} --strip-components=1

WORKDIR "${ACCUMULO_HOME}"

# Build native bindings for accumulo performance
RUN set -x \
  && yum install -y make gcc-c++ \
  && bash -c "bin/build_native_library.sh" \
  && yum remove -y make gcc-c++ \
  && yum -y autoremove

COPY ./fs /

ENTRYPOINT [ "/sbin/entrypoint.sh" ]
