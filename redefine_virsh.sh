#!/bin/sh

config=$1
echo $1

virsh undefine --nvram win11
virsh define $1
