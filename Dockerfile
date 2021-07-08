###
# builder image
###
FROM adoptopenjdk:8-jdk-hotspot-focal AS builder

RUN apt-get update && apt-get install -y git wget

###
# install maven
###
ARG MAVEN_VERSION='3.6.3'
ENV MAVEN_URL "https://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz"
ENV MAVEN_SHA512 'c35a1803a6e70a126e80b2b3ae33eed961f83ed74d18fcd16909b2d44d7dada3203f1ffe726c17ef8dcca2dcaa9fca676987befeadc9b9f759967a8cb77181c0'
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN curl --location --fail --silent --show-error --output /tmp/maven.tar.gz "${MAVEN_URL}" && \
  echo "${MAVEN_SHA512} */tmp/maven.tar.gz" | sha512sum -c -
RUN tar xzf /tmp/maven.tar.gz -C /opt && \
  ln -s "/opt/$(dirname "$(tar -tf /tmp/maven.tar.gz | head -n1)")" /opt/maven && \
  rm /tmp/maven.tar.gz
ENV MAVEN_HOME '/opt/maven'
ENV PATH "${MAVEN_HOME}/bin:${PATH}"

###
# build hbase
###
WORKDIR /tmp
ARG HBASE_REF='master'
ENV HBASE_HOME /opt/hbase
RUN git clone https://github.com/apache/hbase.git --single-branch --depth 1 --branch "${HBASE_REF}"

# patch the in-process zookeeper to bind to all interfaces, otherwise we can't access it from outside the container
# and will be forced to use an external zookeeper cluster (not ideal for testing)
# at time of writing (July 7, 2021) this is the only way to change the bind of the in-process zookeeper
RUN sed -i 's/InetAddress.getLoopbackAddress().getHostName()/"0.0.0.0"/g' \
    ./hbase/hbase-zookeeper/src/main/java/org/apache/hadoop/hbase/zookeeper/MiniZooKeeperCluster.java

RUN mvn clean install -DskipTests assembly:single -f ./hbase/pom.xml
RUN mkdir -p /opt/hbase
RUN find /tmp/hbase/hbase-assembly/target -iname '*.tar.gz' -not -iname '*client*' \
  | head -n 1 \
  | xargs -I{} tar xzf {} --strip-components 1 -C ${HBASE_HOME}

###
# final image
###
FROM adoptopenjdk:8-jre-hotspot-focal
WORKDIR /
ENV HBASE_HOME /opt/hbase
ENV PATH "${HBASE_HOME}/bin:${PATH}"
COPY --from=builder ${HBASE_HOME} ${HBASE_HOME}
ADD configure-using-env.sh configure-using-env.sh
RUN chmod +x configure-using-env.sh && \
    echo "/configure-using-env.sh" >> ${HBASE_HOME}/bin/hbase-config.sh
ENTRYPOINT ["hbase"]
CMD ["master", "start"]

# REST
EXPOSE 8080
# thrift
EXPOSE 9090
# master
EXPOSE 16000
# Master UI
EXPOSE 16010
# regionserver
EXPOSE 16020
# regionserver UI
EXPOSE 16030
