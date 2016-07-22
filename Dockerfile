FROM quay.io/geodocker/hdfs:latest

MAINTAINER Pomadchin Grigory, daunnc@gmail.com

ENV ACCUMULO_VERSION 1.7.2
ENV ACCUMULO_HOME /opt/accumulo
ENV ACCUMULO_CONF_DIR $ACCUMULO_HOME/conf

ENV ZOOKEEPER_HOME /usr/lib/zookeeper

ENV GEOMESA_VERSION 1.2.4
ENV GEOMESA_DIST /opt/geomesa
ENV GEOMESA_HOME ${GEOMESA_DIST}/tools

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
  && yum remove -y make gcc-c++ \
  && yum -y autoremove
  # TODO: Clean up after build_native_library

# GeoMesa Iterators
RUN set -x \
  && mkdir -p ${GEOMESA_DIST} \
  && curl -sS -L http://repo.locationtech.org/content/repositories/geomesa-releases/org/locationtech/geomesa/geomesa-dist/${GEOMESA_VERSION}/geomesa-dist-${GEOMESA_VERSION}-bin.tar.gz \
  | tar -zx -C ${GEOMESA_DIST} --strip-components=2  geomesa-${GEOMESA_VERSION}/dist \
  && tar -xzf ${GEOMESA_DIST}/tools/geomesa-tools-${GEOMESA_VERSION}-bin.tar.gz --strip-components=1 -C ${GEOMESA_DIST}/tools \
  && ${GEOMESA_DIST}/tools/bin/install-jai.sh \
  && ${GEOMESA_DIST}/tools/bin/install-jline.sh \
  && rm -f ${GEOMESA_DIST}/tools/geomesa-tools-${GEOMESA_VERSION}-bin.tar.gz \
  && rm -rf ${GEOMESA_DIST}/gs-plugins \
  && rm -rf ${GEOMESA_DIST}/hadoop \
  && rm -rf ${GEOMESA_DIST}/web-services \
  && rm -rf ${GEOMESA_DIST}/spark


WORKDIR "${ACCUMULO_HOME}"
COPY ./fs /
ENTRYPOINT [ "/sbin/entrypoint.sh" ]
