module CQL
  VERSION = {{ `cat ./shard.yml|awk '/^version:/ {print $2}'`.stringify }}
end
