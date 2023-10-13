/path/to/looking-glass-client >/dev/null 2>&1 & # Starts Looking Glass, and ignores all output (We aren't watching anyways)
/path/to/scream-ivshmem-pulse /dev/shm/scream-ivshmem & # Starts Scream

wait -n # We wait for any of these processes to exit. (Like closing the Looking Glass window, in our case)
pkill -P $$ # We kill the remaining processes (In our case, scream)
