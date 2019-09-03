# hbase-docker

Apache HBase (standalone) for development and testing.

### Version

- HBase: `2.2.0`

### Zookeeper

I chose to run a separate Zookeeper container, instead of using Hbase-standalone's in-process Zookeeper. This is primarily for stability (an Hbase crash does not impact Zookeeper) and reusability (often a stack contains other Zookeeper users).

### Accessing from outside the docker network

The master and region server processes will discover the hostname on which they are running -- there is no way to override the hostname that is advertised. The most reliable approach I have discovered is to assign a hostname to the hbase container, via `--hostname <NAME>` (for `docker run`) or `hostname: <NAME>` (for `docker-compose`). Then, add a loopback entry for this hostname in `/etc/hosts`: `127.0.0.1 <NAME>`.
