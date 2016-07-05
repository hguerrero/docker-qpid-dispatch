#!/usr/bin/env bats

IMAGE="scholzj/qpid-dispatch"
VERSION="devel"

IFSBAK=$IFS
IFS=""
#SERVER_PUBLIC_KEY=$(cat ./test/localhost.crt)
#SERVER_PRIVATE_KEY=$(cat ./test/localhost.pem)
#CLIENT_KEY_DB=$(cat ./test/crt.db)
CONFIG_ANONYMOUS=$(cat ./tests/qdrouterd-anonymous.conf)
IFS=$IFSBAK

teardown() {
    docker stop $cont
    docker rm $cont
}

tcpPort() {
    docker port $cont 5672 | cut -f 2 -d ":"
}

sslPort() {
    docker port $cont 5671 | cut -f 2 -d ":"
}

@test "Worker threads" {
    cont=$(docker run -P -e QDROUTERD_WORKER_THREADS="10" -d $IMAGE:$VERSION)
    sleep 5 # give the image time to start
    wt="$(docker exec -i $cont cat /var/lib/qdrouterd/etc/qdrouterd.conf | grep "workerThreads: 10" | wc -l)"
    [ "$wt" -eq "1" ]
}

#@test "Config file through env variable" {
#    cont=$(sudo docker run -P -e QDROUTERD_CONFIG_OPTIONS="$CONFIG_ANONYMOUS" -d $IMAGE:$VERSION)
#    port=$(tcpPort)
#    sleep 5 # give the image time to start
#    run qpid-config -b localhost:$port list queue
#    [ "$status" -eq "0" ]
#}
