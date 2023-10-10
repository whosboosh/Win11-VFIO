# Win11-VFIO
Collection of scripts and tweaks for making a Windows 11 virtual machine run with QEMU/KVM/libvirt with GPU passthrough.
Thanks to @Pimaker for the original configuration

System details at time of writing:
* Intel i7 12700KF
* 32 GB RAM
* 2080 for Guest, 1660S for Host
* Fedora host machine

Made for VR Gaming, DJ'ing

For Single GPU passthrough there are some scripts at `hooks` which you can use to disable the display manager and unload graphics driver kernel modules. These are DE/WM/GPU vendor agnostic so they should detect various configurations. Inside the hook there is also some pinning I use for my CPU to move the Host machine to use the little cores and the guest uses all the performance cores.

# Additional information
* Network "br0" created using nmcli on the host
* Kernel parameters: `rd.driver.blacklist=nouveau modprobe.blacklist=nouveau nvidia-drm.modeset=0 rhgb intel_iommu=on iommu=pt resume=UUID=24afaf05-41c1-47e3-8521-f62dbbf8ff53 vfio-pci.ids=10de:1e87,10de:10f8,10de:1ad8,10de:1ad9 vfio-pci.disable_vga=1 pcie_acs_override=downstream efifb=off video=efifb:off`
* Host is using an GTX 1660S, the guest an NVIDIA 2080
* USB via passed through via a PCIE USB card, Mouse/Keyboard use SPICE with Looking glass
* Audio works via [Scream](https://github.com/duncanthrax/scream) (using LAN)
* x11vnc is used to VNC back to Host from Guest
* Looking glass is used to interact with the guest (https://looking-glass.io/)