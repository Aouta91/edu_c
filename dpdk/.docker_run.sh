

docker run \
    --name dpdk_build \
    --privileged \
    -it \
    --rm \
    --net=host \
    -v ${PWD}:${PWD} \
    -w ${PWD} \
    ubuntu:22.04 /bin/bash