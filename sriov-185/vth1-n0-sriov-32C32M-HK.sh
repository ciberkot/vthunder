#!/bin/bash -x

numactl --physcpubind=2-10 --membind=0 /usr/bin/qemu-system-x86_64 -enable-kvm \
-name vth-107-numa-0 -M pc -daemonize --enable-kvm -cpu host -smp 8 -m 32G  \
-numa node,memdev=mem -mem-prealloc \
-object memory-backend-file,id=mem,size=32G,mem-path=/dev/hugepages,share=on \
-serial telnet:127.0.0.1:10700,server,nowait,nodelay \
-netdev tap,id=hostnet0,ifname=tapMGMT10 \
-device e1000,netdev=hostnet0,id=net0,mac=60:00:01:07:00:10 \
-device vfio-pci,host=83:0a.0,id=vfnet0 \
-device vfio-pci,host=83:0a.1,id=vfnet1 \
-device vfio-pci,host=83:0e.0,id=vfnet2 \
-device vfio-pci,host=83:0e.1,id=vfnet3 \
-vnc 127.0.0.1:1070 \
-boot order=dc,menu=on \
-uuid 4a9b3f53-fa2a-47f3-a757-dd87720d9d1d \
-drive file=/home/libvirt-qemu/qemu-images/vth-107-numa-0-sriov.qcow2,if=virtio,format=qcow2,index=0,media=disk

brctl addif br105 tapMGMT10

