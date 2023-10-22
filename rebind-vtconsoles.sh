if test -e "/tmp/vfio-bound-consoles"; then
    rm -f /tmp/vfio-bound-consoles
fi
for (( i = 0; i < 16; i++))
do
  if test -x /sys/class/vtconsole/vtcon"${i}"; then
      if [ "$(grep -c "frame buffer" /sys/class/vtconsole/vtcon"${i}"/name)" = 1 ]; then
	      echo 1 > /sys/class/vtconsole/vtcon"${i}"/bind
           echo "$DATE Binding Console ${i}"
           echo "$i" >> /tmp/vfio-bound-consoles
      fi
  fi
done
