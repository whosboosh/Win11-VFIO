#!/bin/sh

virsh undefine --nvram win11
virsh define win11-working.xml
