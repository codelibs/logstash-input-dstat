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
