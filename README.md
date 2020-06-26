# hbase-docker

Apache HBase (standalone) for development and testing.

### Prometheus

The Prometheus JMX exporter is used to expose HBase metrics. See `prometheus-jmx-exporter.yaml` for more details.

### `docker-compose`

I chose to run a separate Zookeeper container, instead of using Hbase-standalone's in-process Zookeeper. This is primarily for stability (an Hbase crash does not impact Zookeeper) and reusability (often a stack contains other Zookeeper users). Additionally, a Prometheus exporter for Zookeeper is included for debuggability.

### Accessing HBase from outside the Docker network

HBase connections are bootstrapped with metadata discovered in Zookeeper. The `docker-compose` file provided in this repository maps both Zookeeper and HBase ports to localhost equivalents, but your applications will still need to resolve the HBase server's hostname to your localhost in order to connect.

It is not possible to override the hostname that is advertised by HBase in Zookeeper. HBase will discover the hostname on which it is running, and use this hostname when registering with Zookeeper. When running HBase inside a container, the hostname will likely be randomized, and hard to work with. I recommend setting a hostname manually, via `--hostname <HOST>` (for `docker run`) or `hostname: <HOST>` (for `docker-compose`).

Add a loopback entry for the HBase hostname in `/etc/hosts`, such as `127.0.0.1 <HOST>`. This will allow applications running on your localhost to connect to HBase running within a Docker network.
