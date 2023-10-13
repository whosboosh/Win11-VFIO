looking-glass-client >/dev/null 2>&1 & # Starts Looking Glass, and ignores all output (We aren't watching anyways)
#scream -i br0 & # Starts Scream

wait -n # We wait for any of these processes to exit. (Like closing the Looking Glass window, in our case)
#pkill -P $$ # We kill the remaining processes (In our case, scream)

