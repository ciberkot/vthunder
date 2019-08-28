 # To show on the host: each PF's and its VFs' Ethernet attributes and PCI
 # number

 # Customize: Total number of 1Gb and 10Gb data ports to be virtualized.
 INTF_SET="enp131s0f0 enp131s0f1 ens2f0 ens2f1"

 # Customize: Here we assume all the interfaces to be virtualized have names
 #            eth1, eth2, eth3, ....

 for intf in `echo $INTF_SET`
 do
 		 echo $intf
         pf_pci=`ethtool -i $intf | grep bus-info | cut -d" " -f 2`
         pf_net_line1=`ip link show dev $intf | egrep -v vf | head -1`
         pf_net_line2=`ip link show dev $intf | egrep -v vf | tail -1`

         vf_num=`ip link show dev $intf | grep vf | wc -l`
         max_vf=$((vf_num-1))

         echo $pf_net_line1
         echo -n "   " $pf_net_line2
         echo " "pci:$pf_pci

         for j in `seq 0 $max_vf`
         do
                 vf_net=`ip link show dev $intf | grep "vf $j"`
                 vf_pci=`ls  -l /sys/bus/pci/devices/${pf_pci}/virtfn${j}`
                 vf_pci=`echo $vf_pci | cut -d">" -f 2 | cut -d"/" -f 2`
                 echo "   " $vf_net pci:$vf_pci
         done
 done
