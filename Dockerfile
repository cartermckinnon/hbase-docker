FROM adoptopenjdk:14-jre-hotspot

RUN apt-get update && \
    apt-get -y install supervisor python-pip net-tools nano wget && \
    pip install supervisor-stdout

# supervisord
RUN mkdir -p /var/log/supervisor
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf
CMD ["/usr/bin/supervisord"]

# hbase binaries
ENV DESTINATION /opt/hbase
ENV PATH $PATH:/${DESTINATION}/bin
ENV HBASE_VERSION 2.2.5
RUN wget http://archive.apache.org/dist/hbase/${HBASE_VERSION}/hbase-${HBASE_VERSION}-bin.tar.gz && \
    tar -xf hbase-${HBASE_VERSION}-bin.tar.gz && \
    mv /hbase-${HBASE_VERSION} ${DESTINATION} && \
    rm hbase-${HBASE_VERSION}-bin.tar.gz

# prometheus JMX exporter
ENV PROMETHEUS_JMX_VERSION 0.13.0
RUN wget https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/${PROMETHEUS_JMX_VERSION}/jmx_prometheus_javaagent-${PROMETHEUS_JMX_VERSION}.jar && \
    mkdir ${DESTINATION}/prometheus && \
    mv /jmx_prometheus_javaagent-${PROMETHEUS_JMX_VERSION}.jar ${DESTINATION}/prometheus/agent.jar
RUN echo 'export HBASE_OPTS="$HBASE_OPTS -javaagent:/opt/hbase/prometheus/agent.jar=8081:/opt/hbase/prometheus/config.yaml"' >> /opt/hbase/conf/hbase-env.sh
ADD prometheus-jmx-exporter.yaml /opt/hbase/prometheus/config.yaml

ADD configure-and-start-master.sh /configure-and-start-master.sh
RUN chmod +x /configure-and-start-master.sh

# REST API
EXPOSE 8080
# Prometheus JMX exporter
EXPOSE 8081
# Thrift API
EXPOSE 9090
# Master port
EXPOSE 16000
# Master info port
EXPOSE 16010
# Regionserver port
EXPOSE 16020
# Regionserver info port
EXPOSE 16030
