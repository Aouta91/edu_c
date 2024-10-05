sudo ip netns delete dpdk_sandbox
# refs
[into](https://habr.com/ru/companies/intel/articles/302126/)
[nvidia dpdk](https://developer.nvidia.com/blog/optimizing-inline-packet-processing-using-dpdk-and-gpudev-with-gpus/)
[CUDA GPU driver by dpdk](https://doc.dpdk.org/guides/gpus/cuda.html)
```sh

make config T=x86_64-native-linuxapp-gcc



wget  https://fast.dpdk.org/rel/dpdk-24.07.tar.xz
tar -xf dpdk-*.tar.gz
tar xJf dpdk-<version>.tar.xz
```

## prepare network namespace
https://habr.com/ru/articles/549414/
```sh
# sudo ip tuntap add mode tap tap0
sudo ip netns delete dpdk_sandbox
ip netns add dpdk_sandbox

ip netns exec dpdk_sandbox bash
ip link set dev lo up
ip link add veth0 type veth peer name veth1
ip link set veth1 netns dpdk_sandbox
veth0@if10


 sudo ip addr add 10.1.1.1/24 dev veth0
 sudo ip link set dev veth0 up

# В пространстве имён dpdk_sandbox
 ip addr add 10.1.1.2/24 dev veth1
 ip link set dev veth1 up
```
## preparing to install dpdk
https://doc.dpdk.org/guides/linux_gsg/sys_reqs.html#compilation-of-the-dpdk

```sh
python3 usertools/cpu_layout.py
python3 usertools/dpdk_nic_bind.py --status
python3 usertools/dpdk-devbind.py --status

sudo apt install meson ninja
sudo apt-get install libnuma-dev

```

```sh
echo 1024 > /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages
python3 usertools/dpdk-hugepages.py 

```


```sh
meson setup  build
cd build


 python3 -m pip install virtualenv
python3 -m ./venv
sudo apt install python3-venv

python3 -m venv  ./.venv
 python3 -c 'import venv'
# .venv/bin/activate
 . .venv/bin/activate

sudo chmod 777 ./.venv/ -R
 pip3 install pyelftools

 python3 -m pip3 install pyelftools
```

## install
```sh 
ninja
meson install
ldconfig

```
