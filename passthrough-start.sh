#!/bin/bash

if [[ $UID -ne 0 ]]; then
	sudo -E bash $0 "$@"
	exit $?
fi

# Necessary for parameter usage in cleanup()
export TMP_PARAMS="$*"
TMP_PARAMS+=" --keep-hugepages "

# Perform cleanup after shutdown
cleanup () {

	# Return CPU power management to default
	pstate-frequency --set -p auto -n 50

	echo $TMP_PARAMS

	if [[ $TMP_PARAMS == *'--keep-hugepages'* ]]
	then
		echo "Skipping hugepage deletion..."
	else
		echo "Deleting hugepages..."
		echo "0" > /proc/sys/vm/nr_hugepages
	fi

	echo "Undoing kernel optimizations..."
	echo fff > /sys/devices/virtual/workqueue/cpumask
	echo fff > /sys/devices/virtual/workqueue/writeback/cpumask
	echo 950000 > /proc/sys/kernel/sched_rt_runtime_us
	sysctl vm.stat_interval=1
        sysctl -w kernel.watchdog=1

	sleep 2
	./qemu_fifo.sh --cleanup
}


if [[ $TMP_PARAMS == *'--cleanup'* ]]
then
	echo "Cleanup only requested!"
	cleanup
	exit 0
fi

# CPU governor settings (keep CPU frequency up, might not work on older CPUs - use cpupower for those)
pstate-frequency --set -p max

# Hugepages config
export HUGEPAGES=16000

# Note that allocating hugepages after boot has a chance to fail. If continuous memory
# cannot be allocated, a reboot will be required.
export STARTING_HUGEPAGES="$(cat /proc/sys/vm/nr_hugepages)"
if [[ "$STARTING_HUGEPAGES" -lt "$HUGEPAGES" ]]; then
    # Drop caches and compact memory to free up continuous memory for huge pages
    echo 3 > /proc/sys/vm/drop_caches
    echo 1 > /proc/sys/vm/compact_memory


    echo "Allocating $HUGEPAGES hugepages..."
    echo "$HUGEPAGES" > /proc/sys/vm/nr_hugepages
    ALLOC_PAGES="$(cat /proc/sys/vm/nr_hugepages)"

    if [[ "$ALLOC_PAGES" -lt "$HUGEPAGES" ]]; then
      echo
      echo 'Not able to allocate hugepages'
      echo "Current max: $ALLOC_PAGES"
      echo

      cleanup
      exit 1
    fi
else
    echo "Hugepages already found, let's use those!"
fi

#echo "Performing minor optimizations prior to launch..."
#sysctl vm.stat_interval=120
#sysctl -w kernel.watchdog=0
#sysctl kernel.sched_rt_runtime_us=1000000

# Start VM via virt-manager
echo "VM starting..."
# Remove existing VM
virsh undefine --nvram win11
virsh define win11-working-lookingglass-7950x3d.xml
virsh start win11
echo

# Start looking glass
sudo -u nate ./start-lookingglass.sh &

sleep 20
./qemu_fifo.sh

# Print status and wait for exit
while [[ $(virsh list --all | grep running) ]]; do
  echo -en "\e[1A\rVM running - " # Weirdness is for formatting
  date
  sleep 1
done

sleep 1
echo "VM has exited"

cleanup
