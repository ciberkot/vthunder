#!/bin/bash -x

numactl --physcpubind=22-25 --membind=1 /usr/bin/qemu-system-x86_64 -enable-kvm \
-name vth-107-numa-1-1 -M pc -daemonize --enable-kvm -cpu host -smp 4 -m 16G  \
-numa node,memdev=mem -mem-prealloc \
-object memory-backend-file,id=mem,size=16G,mem-path=/dev/hugepages,share=on \
-serial telnet:127.0.0.1:10711,server,nowait,nodelay \
-netdev tap,id=hostnet0,ifname=tapMGMT11 \
-device e1000,netdev=hostnet0,id=net0,mac=52:54:01:07:11:01 \
-chardev socket,id=char1,path=/usr/local/var/run/openvswitch/vhost-bond1 \
-netdev type=vhost-user,id=mynet1,chardev=char1,vhostforce \
-device virtio-net-pci,mac=60:00:01:07:11:01,netdev=mynet1 \
-chardev socket,id=char2,path=/usr/local/var/run/openvswitch/vhost-bond3 \
-netdev type=vhost-user,id=mynet2,chardev=char2,vhostforce \
-device virtio-net-pci,mac=60:00:01:07:11:02,netdev=mynet2 \
-vnc 127.0.0.1:10711 \
-boot order=dc,menu=on \
-uuid 4a9b3f53-fa2a-47f3-a757-dd87720d9d1d \
-drive file=/home/libvirt-qemu/images/vth-107-numa-1-KD1.qcow2,if=virtio,format=qcow2,index=0,media=disk

brctl addif br105 tapMGMT11

