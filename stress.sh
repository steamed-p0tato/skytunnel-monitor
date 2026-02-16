#!/bin/bash

# ==========================================
# 1. Start Python HTTP Server
# ==========================================
echo "Starting Python HTTP Server on port 8000..."

# We run this in the background (&) so the script can continue
# We redirect output to /dev/null so server logs don't mess up the screen
python -m http.server 8000 > /dev/null 2>&1 &

# Capture the Process ID (PID) of the python server so we can kill it later
SERVER_PID=$!

echo "Server running (PID: $SERVER_PID). Starting tunnel loop..."
sleep 2

# ==========================================
# 2. cleanup Function
# ==========================================
# This runs when you press Ctrl+C to ensure the python server shuts down
cleanup() {
    echo ""
    echo "Shutting down..."
    
    # Kill the Python server
    if kill -0 $SERVER_PID 2>/dev/null; then
        echo "Stopping Python Server (PID: $SERVER_PID)..."
        kill $SERVER_PID
    fi

    # Kill any remaining SSH tunnels
    echo "Cleaning up tunnels..."
    pkill -f "ssh -p 2222 -R 0:localhost:8000 free@free.skytunnel.dev"
    
    exit
}

# Trap the Ctrl+C signal (SIGINT)
trap cleanup SIGINT

# ==========================================
# 3. The Tunnel Loop
# ==========================================
while true; do
    # Generate random number between 31 and 48
    COUNT=$(( ( RANDOM % 18 ) + 31 ))
    
    echo "------------------------------------------"
    echo "Cycle Start: Opening $COUNT tunnels"
    echo "------------------------------------------"

    for (( i=1; i<=COUNT; i++ )); do
        ssh -p 2222 -R 0:localhost:8000 free@free.skytunnel.dev -N -f > /dev/null 2>&1
        # Slight delay to prevent network choking
        sleep 0.2
    done

    echo "$COUNT tunnels active."
    echo "Waiting 10 minutes..."

    # Wait 10 minutes (600 seconds)
    sleep 600

    echo "Time is up! Refreshing tunnels..."

    # Kill only the tunnels (keep Python server running)
    pkill -f "ssh -p 2222 -R 0:localhost:8000 free@free.skytunnel.dev"
    
    echo "Restarting loop in 2 seconds..."
    sleep 2
done
