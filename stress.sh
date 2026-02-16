#!/bin/bash

# Infinite loop to keep the process going forever
while true; do
    # 1. Generate a random number between 31 and 48
    # $(( RANDOM % 18 )) gives 0-17. Adding 31 gives 31-48.
    COUNT=$(( ( RANDOM % 18 ) + 31 ))
    
    echo "=========================================="
    echo "Starting new cycle: Opening $COUNT tunnels"
    echo "=========================================="

    # 2. Loop to open the specific number of tunnels
    for (( i=1; i<=COUNT; i++ )); do
        # -N: Do not execute a remote command (just forward ports)
        # -f: Go to background
        # We redirect output to /dev/null to keep the screen clean, 
        # remove "> /dev/null 2>&1" if you want to see the port numbers assigned.
        ssh -p 2222 -R 0:localhost:8000 free@free.skytunnel.dev -N -f > /dev/null 2>&1
        
        # A tiny pause is healthy to prevent choking your network adapter
        sleep 0.2
    done

    echo "$COUNT tunnels are now active."
    echo "Waiting 10 minutes..."

    # 3. Wait for 600 seconds (10 minutes)
    sleep 600

    echo "Time is up! Disconnecting all tunnels..."

    # 4. Kill only the specific SSH processes we started
    pkill -f "ssh -p 2222 -R 0:localhost:8000 free@free.skytunnel.dev"

    echo "All tunnels closed. Restarting in 2 seconds..."
    sleep 2
done
