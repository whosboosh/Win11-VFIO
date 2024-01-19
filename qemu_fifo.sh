#!/bin/bash

arg="$1"
shift
if [ "$arg" == "--cleanup" ]; then
	echo "Cleanup qemu fifo"
	grep ahci /proc/interrupts | cut -d ":" -f 1 | while read -r i; do echo $i; MASK=0; echo $MASK > /proc/irq/$i/smp_affinity_list; done
	exit 0
fi

if [[ $(sudo virsh list --all | grep running) ]]; then
  echo "VM running, performing action"
else
  echo "VM no longer running, aborting"
  exit 1
fi


echo
echo
