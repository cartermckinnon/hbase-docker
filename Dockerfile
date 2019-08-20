FROM openjdk:8-jre

RUN apt-get update && \
    apt-get -y install supervisor python-pip net-tools nano wget && \
    pip install supervisor-stdout

# supervisord
RUN mkdir -p /var/log/supervisor
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf
CMD ["/usr/bin/supervisord"]

# hbase binaries
ENV DESTINATION /opt/hbase
ENV VERSION 2.2.0
RUN wget http://archive.apache.org/dist/hbase/${VERSION}/hbase-${VERSION}-bin.tar.gz && \
    tar -xf hbase-${VERSION}-bin.tar.gz && \
    mv /hbase-${VERSION} ${DESTINATION} && \
    rm hbase-${VERSION}-bin.tar.gz

ENV JAVA_HOME /usr/local/openjdk-8
ENV PATH $PATH:/${DESTINATION}/bin

# wait-for-it
RUN wget https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh -O /wait-for-it.sh
RUN chmod +x /wait-for-it.sh

# REST API
EXPOSE 8080
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
