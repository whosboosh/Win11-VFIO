looking-glass-client -f /dev/kvmfr0 >/dev/null 2>&1 & # Starts Looking Glass, and ignores all output (We aren't watching anyways)

wait -n # We wait for any of these processes to exit. (Like closing the Looking Glass window, in our case)

