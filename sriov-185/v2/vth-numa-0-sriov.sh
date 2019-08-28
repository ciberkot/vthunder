#!/bin/bash -x

numactl --physcpubind=2-13 --membind=0 /usr/bin/qemu-system-x86_64 -enable-kvm \
-name vth-107-numa-0 -M pc -daemonize --enable-kvm -cpu host -smp 12 -m 16G  \
-numa node,memdev=mem -mem-prealloc \
-object memory-backend-file,id=mem,size=16G,mem-path=/dev/hugepages,share=on \
-serial telnet:127.0.0.1:10710,server,nowait,nodelay \
-netdev tap,id=hostnet0,ifname=tapMGMT10 \
-device e1000,netdev=hostnet0,id=net0,mac=60:00:01:07:00:10 \
-device vfio-pci,host=03:10.0,id=vfnet2 \
-device vfio-pci,host=03:10.1,id=vfnet3 \
-device vfio-pci,host=01:10.0,id=vfnet0 \
-device vfio-pci,host=01:10.1,id=vfnet1 \
-vnc 127.0.0.1:1070 \
-boot order=c,menu=on \
-uuid 4a9b3f53-fa2a-47f3-a757-dd87720d9d1d \
-drive file=/home/libvirt-qemu/images/vth-107-numa-0-sriov-v2.qcow2,format=qcow2,if=virtio,index=0,media=disk
#-cdrom /home/corpse/ACOS_vThunder_4_1_2-P2_68.iso

brctl addif br105 tapMGMT10

