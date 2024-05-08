#!/bin/sh

name=win10
while getopts "n:" arg; do
  case $arg in
    n)
      name=${OPTARG}
	  shift
      ;;
  esac
done

virsh undefine --nvram $name
virsh define $1
