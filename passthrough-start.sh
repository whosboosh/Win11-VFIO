#!/bin/bash

# Necessary for parameter usage in cleanup()
export TMP_PARAMS="$*"
TMP_PARAMS+=" --keep-hugepages "

# Perform cleanup after shutdown
cleanup () {

	# Return CPU power management to default
	pstate-frequency --set -p auto -n 50

	echo $TMP_PARAMS

	echo "Deleting hugepages..."
	echo "0" > /proc/sys/vm/nr_hugepages
	echo "Undoing kernel optimizations..."
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

name=win11
redefine=
optimisations=
start=
while getopts "orpn:" o; do
    case "${o}" in
    o)
      optimisations=true
      ;;
    r)
      redefine=true
      ;;
    n)
      name=${OPTARG}
	  shift
      ;;
	p)
	  start=true
	  ;;
  esac
done

echo redefine: $redefine
echo name: $name
echo start: $start

if [ ! -z $optimisations ]; then
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

	echo "Performing minor optimizations prior to launch..."
    # schedule real-time processes to have more CPU time
    echo 1000000 > /proc/sys/kernel/sched_rt_runtime_us
    # Reduce the virtual memory stat interval to stop polling every second by default
    # and reduce interrupts
	sysctl vm.stat_interval=120
    # Disable the kernel watchdog timer to prevent NMI interrupts from occuring on lockup detection
    sysctl -w kernel.watchdog=0
fi

# Set GPU to vfio-pci
#driverctl set-override 0000:01:00.0 vfio-pci
#driverctl set-override 0000:01:00.1 vfio-pci
#driverctl set-override 0000:16:00.0 vfio-pci

if [ ! -z $redefine ]; then
# Remove existing VM
	virsh undefine --nvram $name
	virsh define $name-working-lookingglass-7950x3d.xml
fi

if [ ! -z $start ]; then
	# Start VM via virt-manager
	echo "VM starting..."
	virsh start $name

	sleep 120
	./qemu_fifo.sh
fi

# Print status and wait for exit
while [[ $(virsh list --all | grep running) ]]; do
  echo -en "\e[1A\rVM running - " # Weirdness is for formatting
  date
  sleep 1
done

sleep 1
echo "VM has exited"

cleanup
