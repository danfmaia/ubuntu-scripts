#!/bin/bash

# Cursor Performance Monitoring Script
# This script monitors Cursor's resource usage and provides insights

echo "🔍 Cursor Performance Monitor 🔍"
echo "==============================="
echo ""

# Check if Cursor is running
if ! pgrep -x "cursor" > /dev/null; then
    echo "❌ Cursor is not currently running."
    exit 1
fi

# Get Cursor process IDs
CURSOR_PIDS=$(pgrep -f "cursor")
echo "Found $(echo "$CURSOR_PIDS" | wc -l) Cursor processes"

# Monitor CPU and memory usage
echo -e "\n📊 Current Resource Usage:"
echo "----------------------------"
echo -e "PID\tCPU%\tMEM%\tCOMMAND"
echo "----------------------------"

for PID in $CURSOR_PIDS; do
    # Get process info
    CPU_USAGE=$(ps -p $PID -o %cpu | tail -n 1 | tr -d ' ')
    MEM_USAGE=$(ps -p $PID -o %mem | tail -n 1 | tr -d ' ')
    COMMAND=$(ps -p $PID -o cmd | tail -n 1 | cut -c 1-50)
    
    # Highlight high resource usage
    if (( $(echo "$CPU_USAGE > 20" | bc -l) )); then
        CPU_STR="\e[31m$CPU_USAGE%\e[0m"  # Red for high CPU
    elif (( $(echo "$CPU_USAGE > 10" | bc -l) )); then
        CPU_STR="\e[33m$CPU_USAGE%\e[0m"  # Yellow for medium CPU
    else
        CPU_STR="$CPU_USAGE%"
    fi
    
    if (( $(echo "$MEM_USAGE > 10" | bc -l) )); then
        MEM_STR="\e[31m$MEM_USAGE%\e[0m"  # Red for high memory
    elif (( $(echo "$MEM_USAGE > 5" | bc -l) )); then
        MEM_STR="\e[33m$MEM_USAGE%\e[0m"  # Yellow for medium memory
    else
        MEM_STR="$MEM_USAGE%"
    fi
    
    echo -e "$PID\t$CPU_STR\t$MEM_STR\t$COMMAND"
done

# Check for high CPU usage processes
echo -e "\n🔥 Top 5 CPU-Intensive Processes:"
echo "-----------------------------------"
ps -eo pid,pcpu,pmem,comm --sort=-pcpu | head -n 6

# Check Cursor cache size
echo -e "\n💾 Cursor Cache Size:"
echo "---------------------"
CACHE_SIZE=$(du -sh ~/.config/Cursor/Cache 2>/dev/null | cut -f1)
CACHED_DATA_SIZE=$(du -sh ~/.config/Cursor/CachedData 2>/dev/null | cut -f1)
CODE_CACHE_SIZE=$(du -sh ~/.config/Cursor/Code\ Cache 2>/dev/null | cut -f1)
GPU_CACHE_SIZE=$(du -sh ~/.config/Cursor/GPUCache 2>/dev/null | cut -f1)

echo "Cache: $CACHE_SIZE"
echo "Cached Data: $CACHED_DATA_SIZE"
echo "Code Cache: $CODE_CACHE_SIZE"
echo "GPU Cache: $GPU_CACHE_SIZE"

# Check extension count
echo -e "\n🧩 Extension Information:"
echo "-------------------------"
EXTENSION_COUNT=$(ls -la ~/.cursor/extensions/ | wc -l)
echo "Total extensions: $EXTENSION_COUNT"

# Check system resources
echo -e "\n💻 System Resources:"
echo "-------------------"
echo "Memory Usage:"
free -h | grep "Mem:" | awk '{print "Total: " $2 "  Used: " $3 "  Free: " $4}'

echo -e "\nDisk Usage:"
df -h | grep "/$" | awk '{print "Total: " $2 "  Used: " $3 "  Free: " $4 "  Use%: " $5}'

echo -e "\n✅ Monitoring Complete"
echo ""
echo "Recommendations:"
echo "1. If Cursor is using >50% CPU consistently, consider restarting it"
echo "2. If cache sizes are >1GB, consider running the cleanup script"
echo "3. For immediate performance boost, disable unnecessary extensions"
echo "4. Run this script periodically to monitor performance trends"
echo ""
echo "For more detailed performance analysis, run:"
echo "htop -p \$(pgrep -f cursor | tr '\n' ',')" 