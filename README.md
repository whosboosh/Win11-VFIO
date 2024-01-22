# Win11-VFIO
Collection of scripts and tweaks for making a Windows 11 virtual machine run with QEMU/KVM/libvirt with GPU passthrough.
Thanks to @Pimaker for the original configuration

System details at time of writing:
* AMD Ryzen 9 7950X3D
* 64GB DDR5
* RTX 3090 for Guest, AMD RX 570 for Host (Experimenting with 1660S atm)
* Fedora host OS

Made for VR Gaming, DJ'ing

For Single GPU passthrough there are some scripts at `hooks` which you can use to disable the display manager and unload graphics driver kernel modules. These are DE/WM/GPU vendor agnostic so they should detect various configurations. Inside the hook there is also some pinning I use for my CPU to move the Host machine to use the little cores and the guest uses all the performance cores.

# Hugepages are allocated on boot
* See [Redhat Huge Pages](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/performance_tuning_guide/sect-red_hat_enterprise_linux-performance_tuning_guide-memory-configuring-huge-pages) for creating a service file to do this at boot. Otherwise the script will allocate them at runtime which can fail. I made some edits to allocate 16GB to the shell script
```
#!/bin/sh

nodes_path=/proc/sys/vm/nr_hugepages
reserve_pages()
{
    # Drop caches and compact memory to free up continuous memory for huge pages
    echo 3 > /proc/sys/vm/drop_caches
    echo 1 > /proc/sys/vm/compact_memory
    echo $1 > $nodes_path
}

reserve_pages 9000
```

# Additional information
* Network "br0" created using nmcli on the host
* Kernel parameters: `vfio-pci.ids=10de:2204,10de,1aef amd_iommu=on iommu=pt kvm.ignore_msrs=1 amd_pstate=passive mitigations=off rd.driver.pre=vfio-pci resume=UUID=24afaf05-41c1-47e3-8521-f62dbbf8ff53 hugepagesz=11000 default_hugepagesz=2048K rd.driver.blacklist=nouveau modprobe.blacklist=nouveau crashkernel=256M preempt=voluntary nvidia-drm.modeset=1 systemd.unified_cgroup_hierarchy=1 pcie_acs_override=downstream,multifunction vfio_iommu_type1.allow_unsafe_interrupts=1`
* USB via passed through via a PCIE USB card, Mouse/Keyboard use SPICE with Looking glass
* Audio works via [Scream](https://github.com/duncanthrax/scream) (using LAN)
* x11vnc is used to VNC back to Host from Guest
* Looking glass is used to interact with the guest (https://looking-glass.io/)
