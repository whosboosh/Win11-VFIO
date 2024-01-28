#!/bin/bash

HCPUS=8-15,24-31
MCPUS=0-7,16-23
ACPUS=0-31

disable_isolation () {
        vfio-isolate \
                cpuset-modify --cpus C$ACPUS /system.slice \
                cpuset-modify --cpus C$ACPUS /user.slice \
                irq-affinity mask C$ACPUS

        taskset -pc 0-23 2  # kthreadd reset
}

enable_isolation () {
        chrt -a -f -p 99 $(pidof qemu-system-x86_64)
        echo "Set QEMU execution policy!"
        chrt -p $(pidof qemu-system-x86_64)

        vfio-isolate \
                drop-caches \
                cpuset-modify --cpus C$HCPUS /system.slice \
                cpuset-modify --cpus C$HCPUS /user.slice \
                                                                move-tasks / /system.slice \
                compact-memory \
                irq-affinity mask C$MCPUS

        taskset -pc $HCPUS 2  # kthreadd only on host cores
}

arg="$1"
shift
if [ "$arg" == "--cleanup" ]; then
	ec\ho "Cleanup qemu fifo"
	disable_isolation
	exit 0
fi

if [[ $(sudo virsh list --all | grep running) ]]; then
  echo "VM running, performing action"
  enable_isolation
else
  echo "VM no longer running, aborting"
  disable_isolation
  exit 1
fi
