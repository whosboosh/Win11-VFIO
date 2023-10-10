#!/bin/sh
sudo setsebool -P domain_can_mmap_files 1
sudo semodule -X 300 -i my-qemusystemx86.pp
sudo ausearch -c 'qemu-system-x86' --raw | audit2allow -M my-qemusystemx8