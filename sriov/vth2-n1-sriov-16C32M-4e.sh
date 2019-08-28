#!/bin/bash -x

 # To change the number of SoftAX: add softaxX_pcidev softax_pcidevs
 # and "for i in ...". And copy more/fewer images.
 # and change max_vfs when loading the kernel module.

 # Step 1: Assign SR-IOV PCI numbers to different SoftAX
 # Customize: Replace them with the PCIe numbers in your system.


 #softax_pcidev="83:02.1,83:0a.1,85:02.1,85:0a.1,83:02.0,83:0a.0,85:02.0,85:0a.0"
 softax_pcidev="83:02.0,83:0a.0,85:02.0,85:0a.0"
 #softax_pcidev="83:02.0,85:02.0"


#softax_pcidevs=("$softax0_pcidev" "$softax1_pcidev" "$softax2_pcidev" "$softax3_pcidev" "$softax4_pcidev" "$softax5_pcidev")


 # Step 2: Launch SoftAX0, SoftAX1, .... SoftAX5

 # Customize: Specify the maximum SoftAX ID
 MAX_SOFTAX_ID=0
 WHERE=`whereiam $0`

 for i in 1
 do

         # Setup parameters for SoftAX x
#        UUID=`head -$((1+i)) /root/softax_images/softax_uuids | tail -1`

         # Customize: Replace this with your own MAC assignment scheme.
         #            Make sure MAC is unique accross multiple hosts!
#         uuid_tail=`echo $UUID | cut -c 35-36`
         MAC=52:54:00:11:22:$((51 + $i))

         # Management interface
         TAP=tap$((1 + $i))

         # Disk image.
         # Assume: already copy distributed disk image to
         #         /root/softax_images/softax-sr-iov-${i}.img
#         FILE=softax-sr-iov-0.img
         FILE=/home/libvirt-qemu/images/vth-107-numa-1-sriov.qcow2

         NAME=vth${i}

         # Serial port of SoftAX can be accessed through
         # "telnet localhost $SERIAL_TCP_PORT"
         SERIAL_TCP_PORT=$((10001 + $i))

         VNC_PORT=$((51 + $i))

         # Assign PCI devices listed in softax_pcidevn to this SoftAX.
         # Convert softax_pcidevn into kvm command parameter of pci-assign.
                 #pcidev_list=${softax_pcidevs[$i]}
         pcidev_list=$softax_pcidev
         pcidev_num=`echo $pcidev_list | tr -cd ":" | wc -c`
         DEVICE_GBEVF=" "
         for j in `seq $pcidev_num`
         do
                                 echo $DEVICE_GBEVF
                 nextdev=`echo $pcidev_list | cut -d, -f $j`
                 DEVICE_GBEVF=$DEVICE_GBEVF" -device vfio-pci,host="$nextdev",id=vfnet"$(($j-1))
         done

         # -smp 1: SoftAX only supports 1 vCPU
         # -m 4096: Minimum memory recommended is 4GB.
         # console output redirected to /root/softax_images/logs/${NAME}_${date}.log


                numactl --physcpubind=18-35 --membind=1 /usr/bin/qemu-system-x86_64 -enable-kvm \
                -name $NAME -M pc -daemonize --enable-kvm -cpu host -smp 16 -m 32G  \
                -numa node,memdev=mem -mem-prealloc \
                -object memory-backend-file,id=mem,size=32G,mem-path=/dev/hugepages,share=on \
                -serial telnet:127.0.0.1:${SERIAL_TCP_PORT},server,nowait,nodelay \
                -netdev tap,id=hostnet0,ifname=${TAP} \
                -device e1000,netdev=hostnet0,id=net0,mac=$MAC,bus=pci.0,addr=0x3 \
                $DEVICE_GBEVF \
                -vnc 127.0.0.1:${VNC_PORT} \
                -boot order=dc,menu=on \
                -uuid 4a9b3f53-fa2a-47f3-a757-dd87720d9d1d \
                -drive file=${FILE},if=virtio,format=qcow2,index=0,media=disk

        done
        brctl addif br105 $TAP

