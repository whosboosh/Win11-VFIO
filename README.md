# Win11-VFIO
Collection of scripts and tweaks for making a Windows 11 virtual machine run with QEMU/KVM/libvirt with GPU passthrough.
Thanks to @Pimaker for the original configuration

System details at time of writing:
* AMD Ryzen 9 7950X3D
* 64GB DDR5
* RTX 3090 for Guest, IGPU for host 2 displays
* Fedora host OS (6.8.12-300.vfio.fc40.x86_64)

Made for VR Gaming, DJ'ing

For Single GPU passthrough there are some scripts at `hooks` which you can use to disable the display manager and unload graphics driver kernel modules. These are DE/WM/GPU vendor agnostic so they should detect various configurations. Inside the hook there is also some pinning I use for my CPU to move the Host machine to use the little cores and the guest uses all the performance cores.

# Additional information
* Network "br0" created using nmcli on the host
* Kernel parameters: `amd_pstate=passive mitigations=off rd.driver.pre=vfio-pci crashkernel=256M preempt=voluntary systemd.unified_cgroup_hierarchy=1 pcie_acs_override=downstream,multifunction transparent_hugepage=never rcu_nocbs=0-7,16-23 nohz_full=0-7,16-23 nmi_watchdog=0 amd_iommu=force_enable iommu=pt clocksource=tsc clock=tsc force_tsc_stable=1 pcie_aspm.policy=performance`
* USB via passed through via a PCIE USB card, Mouse/Keyboard use SPICE with Looking glass
* Audio works via Spice, [Scream](https://github.com/duncanthrax/scream) also works (using LAN)
* Looking glass is used to interact with the guest (https://looking-glass.io/)
    * Using the KVMFR kernel driver with AMD GPU on the host for direct DMA memory access from VM -> Host
    * See dotfiles for configs


# Custom patches
* https://github.com/Precific/qemu-cppc
    - qemu-cppc provides the VM with access to the internal AMD CPPC configuration defining which cores to prefer. Despite using the entire CCU with vcache in the VM I still find these patches add stability to my build. Requires building a custom kernel and qemu with the patches applied.
* https://github.com/benbaker76/linux-acs-override
    - My motherboard does not group each x16 PCIE slot in its own IOMMU group so the downstream multifunction patch is required in the kernel for proper isolation with VFIO.