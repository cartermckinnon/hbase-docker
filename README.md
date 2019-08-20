# hbase-docker

Apache HBase (standalone) for development and testing.

### Version

- HBase: `2.2.0`

### Zookeeper

I chose to run a separate Zookeeper container, instead of using Hbase-standalone's in-process Zookeeper. This is primarily for stability (an Hbase crash does not impact Zookeeper) and reusability (often a stack contains other Zookeeper users).
