
#!/bin/bash
# Create CPU load for demo - uses your infinite loop trick!

DURATION=${1:-30}        # Default 30 seconds
TOTAL_CORES=$(nproc)     # Total cores available
CORES_TO_STRESS=${2:-$TOTAL_CORES}  # Default: all cores

# Validate cores parameter
if ! [[ "$CORES_TO_STRESS" =~ ^[0-9]+$ ]]; then
    echo "❌ Error: Cores must be a number"
    echo "Usage: $0 <duration> <cores>"
    echo "Example: $0 30 2"
    exit 1
fi

if [ "$CORES_TO_STRESS" -lt 1 ] || [ "$CORES_TO_STRESS" -gt "$TOTAL_CORES" ]; then
    echo "❌ Error: Cores must be between 1 and $TOTAL_CORES"
    echo "Usage: $0 <duration> <cores>"
    exit 1
fi

echo "=========================================="
echo "  CPU Load Generator for Demo"
echo "=========================================="
echo "Total cores available: $TOTAL_CORES"
echo "Cores to stress: $CORES_TO_STRESS"
echo "Duration: ${DURATION}s"
echo "Expected CPU: ~$((CORES_TO_STRESS * 100 / TOTAL_CORES))%"
echo ""
echo "Creating load in 3 seconds..."
echo "Watch the agent terminal and dashboard!"
sleep 3

# Start background loops for specified number of cores
echo "Starting load..."
for i in $(seq 1 $CORES_TO_STRESS); do
    while true; do :; done &
    PIDS="$PIDS $!"
done

echo "✅ Load active on $CORES_TO_STRESS of $TOTAL_CORES cores!"
echo "   PID list: $PIDS"
echo ""
echo "⏱️  Running for ${DURATION} seconds..."

# Wait for specified duration
sleep $DURATION

# Kill all the loops
echo ""
echo "🛑 Stopping load..."

# Try graceful kill first
if [ -n "$PIDS" ]; then
    kill $PIDS 2>/dev/null
    sleep 1
    
    # Check if any are still running, force kill if needed
    for pid in $PIDS; do
        if kill -0 $pid 2>/dev/null; then
            echo "   Force killing stuck process $pid..."
            kill -9 $pid 2>/dev/null
        fi
    done
    
    echo "✅ Load stopped!"
else
    echo "⚠️  No processes to kill (load may not have started)"
fi

echo ""
echo "Check dashboard to see mode return to BALANCED"
echo ""
echo "💡 Tip: Try different core counts:"
echo "   $0 30 1   # Light load (~25% CPU) → MODERATE"
echo "   $0 30 2   # Medium load (~50% CPU) → POWER_SAVE"
echo "   $0 30 $TOTAL_CORES   # Heavy load (100% CPU) → CRITICAL"
