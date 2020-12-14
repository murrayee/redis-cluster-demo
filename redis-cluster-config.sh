for port in $(seq 7000 7005); do
  mkdir -p ./data/${port}/conf && PORT=${port} IPEND=1${port:0-1:1} envsubst <./redis-cluster.tmpl >./data/${port}/conf/redis.conf && mkdir -p ./data/${port}/data
done

