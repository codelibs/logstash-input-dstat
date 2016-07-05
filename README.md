# Logstash Plugin

This is a plugin for [Logstash](https://github.com/elastic/logstash). This plugin behave like a [fluent-plugin-dstat](https://github.com/shun0102/fluent-plugin-dstat) on logsash.


## install

- Install plugin
```sh
bin/logstash-plugin install logstash-input-dstat
```

## Configuration

```
input {
  dstat {
    option => "-c"
    interval => 30
  }
}

output {
  elasticsearch {
    hosts => ["localhost:9200"]
  }
}
```

### parameters

* option
    * option for dstat
* interval
    * interval for executing dstat
* stat_hash
    * set custom stat mapping

### default stat mapping

``` ruby
{
  'load avg' => {'1m' => 'loadavg-short', '5m' => 'loadavg-middle', '15m' => 'loadavg-long'},
  'total cpu usage' => {'usr' => 'cpu-usr', 'sys' => 'cpu-sys', 'idl' => 'cpu-idl', 'wai' => 'cpu-wai', 'hiq' => 'cpu-hiq', 'siq' => 'cpu-siq'},
  'net/total' => {'recv' => 'net-recv', 'send' => 'net-send'},
  '/' => {'used' => 'disk-used', 'free' => 'disk-free'},
  'memory usage' => {'used' => 'mem-used', 'buff' => 'mem-buff', 'cach' => 'mem-cach', 'free' => 'mem-free'},
  'dsk/total' => {'read' => 'dsk-read', 'writ' => 'dsk-writ'},
  'paging' => {'in' => 'paging-in', 'out' => 'paging-out'},
  'system' => {'int' => 'sys-int', 'csw' => 'sys-csw'},
  'swap' => {'used' => 'swap-used', 'free' => 'swap-free'},
  'procs' => {'run' => 'procs-run', 'blk' => 'procs-blk', 'new' => 'procs-new'}
}
```
