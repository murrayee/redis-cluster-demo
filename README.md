单机版redis集群搭建(哨兵模式)：

#### 创建网关：
```
docker network create --driver bridge --subnet 172.21.0.0/180 --gateway 172.21.0.1 redis-net

```
一定要自定义指定ip段 ` --subnet 172.21.0.0/180`
创建成功后查看`docker inspect redis-net`网关ip，来配置`redis-cluster.tmpl`中的`cluster-announce-ip`

#### 生成配置文件

```
    ./redis-cluster-config.sh
```

#### 生成镜像

```
    docker-compose up -d
```

#### 配置集群
当镜像启动完：
- 1、 组建集群
```
for N in `seq 10 15` ; do 
     redis-cli -h 172.21.0.10 -p 7000 -a 123456 cluster meet 172.21.0.${N} 700${N:1:1};
 done

````

- 2、查看集群节点
```
 redis-cli -h 172.21.0.10 -p 7000 -a 123456 cluster nodes
```
- 3、分配slot
```
 redis-cli -h 172.21.0.10 -p 7000 -a 123456  CLUSTER ADDSLOTS {0,5461}
 redis-cli -h 172.21.0.11 -p 7001 -a 123456  CLUSTER ADDSLOTS {5462,10922}
 redis-cli -h 172.21.0.12 -p 7002 -a 123456  CLUSTER ADDSLOTS {10923,16383}
```
- 4、拿到节点标识设置主从关系
```
redis-cli -h 172.21.0.13 -p 7003 -a 123456 CLUSTER REPLICATE 8ded936820cdb95f537ec5980808436c3c385cd1
redis-cli -h 172.21.0.14 -p 7004 -a 123456 CLUSTER REPLICATE 34e5ce612d4e9fd4b04df84966c8565a690fc0ec
redis-cli -h 172.21.0.15 -p 7005 -a 123456 CLUSTER REPLICATE 06eff2244ccb1790e4a9665fe465d07bda193c84
```

- 5、设置集群密码
```
for n in `seq 0 5` ; do 
     # 为每个节点设相同密码
     redis-cli -h 172.21.0.1${n} -p 700${n} -a 123456 config set requirepass 123456;
     # 为slave节点设置主节点的密码，可能用于同步主节点数据验证使用(我这里为所有节点都设置了)
     redis-cli -h 172.21.0.1${n} -p 700${n} -a 123456 config set masterauth 123456;
 done
 ```
