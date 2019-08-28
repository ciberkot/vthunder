#!/bin/bash -x

numactl --physcpubind=20-35 --membind=1 /usr/bin/qemu-system-x86_64 -enable-kvm \
-name vth-107-numa-1 -M pc -daemonize --enable-kvm -cpu host -smp 8 -m 16G  \
-numa node,memdev=mem -mem-prealloc \
-object memory-backend-file,id=mem,size=16G,mem-path=/dev/hugepages,share=on \
-serial telnet:127.0.0.1:10701,server,nowait,nodelay \
-netdev tap,id=hostnet0,ifname=tapMGMT11 \
-device e1000,netdev=hostnet0,id=net0,mac=60:00:01:07:01:11 \
-device vfio-pci,host=81:06.0,id=vfnet0 \
-device vfio-pci,host=81:0e.0,id=vfnet1 \
-vnc 127.0.0.1:1071 \
-boot order=dc,menu=on \
-uuid 4a9b3f53-fa2a-47f3-a757-dd87720d9d1d \
-drive file=/home/libvirt-qemu/qemu-images/vth-107-numa-1-sriov.qcow2,if=virtio,format=qcow2,index=0,media=disk

brctl addif br105 tapMGMT11
