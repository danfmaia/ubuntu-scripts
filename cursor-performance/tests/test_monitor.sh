#!/bin/bash

# Test for cursor-monitor.sh
# Tests the performance monitor script using a mock environment

# Load test utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/test_utils.sh"

# Set up mock environment
test_setup() {
    # Create mock directories
    mkdir -p "${MOCK_HOME}/processes"
    
    # Mock processes
    echo "3" > "${MOCK_HOME}/processes/cursor"
}

# Create a modified version of the monitor script for testing
create_test_script() {
    # Create a temporary script with modified paths
    local TEMP_SCRIPT="${SCRIPT_DIR}/temp_monitor_script.sh"
    
    # Read the original script
    cat "${PERF_SCRIPTS_DIR}/cursor-monitor.sh" > "${TEMP_SCRIPT}"
    
    # Replace paths and commands - use different delimiter to avoid sed issues
    sed -i "s|~|${MOCK_HOME}|g" "${TEMP_SCRIPT}"
    sed -i "s|\${GREEN}||g; s|\${YELLOW}||g; s|\${RED}||g; s|\${NC}||g; s|\${BOLD}||g; s|\${BLUE}||g" "${TEMP_SCRIPT}"
    sed -i "s|echo -e|echo|g" "${TEMP_SCRIPT}"
    
    # Disable clear command and interactive prompts
    sed -i "s|clear|: # clear disabled|g" "${TEMP_SCRIPT}"
    
    # Override functions using test mocks
    cat >> "${TEMP_SCRIPT}" << EOF
# Mock ps for testing
ps() {
    if [[ "\$1" == "aux" ]]; then
        echo "USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND"
        echo "user     10001 25.0  5.0 123456 54321 ?        Sl   10:00   1:30 /usr/bin/cursor --type=renderer"
        echo "user     10002  5.0  2.0 123456 54321 ?        Sl   10:00   0:30 /usr/bin/cursor --type=gpu-process"
        echo "user     10003  1.0  1.0 123456 54321 ?        Sl   10:00   0:10 /usr/bin/cursor --type=utility"
    fi
    return 0
}

# Mock pgrep for testing
pgrep() {
    mock_pgrep "\$@"
}

# Mock free for testing
free() {
    mock_free "\$@"
}

# Mock top for testing
top() {
    if [[ "\$1" == "-b" && "\$2" == "-n" && "\$3" == "1" ]]; then
        echo "top - 12:00:00 up 1 day, 2:00, 1 user, load average: 1.00, 0.75, 0.50"
        echo "Tasks: 100 total,   1 running,  99 sleeping,   0 stopped,   0 zombie"
        echo "%Cpu(s): 10.0 us,  5.0 sy,  0.0 ni, 85.0 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st"
        echo "MiB Mem :  16000.0 total,   5000.0 free,   8000.0 used,   3000.0 buff/cache"
        echo "MiB Swap:   8000.0 total,   7000.0 free,   1000.0 used.   7000.0 avail Mem"
        echo ""
        echo "  PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND"
        echo "10001 user      20   0  123456  54321  12345 S  25.0   5.0   1:30.00 cursor --type=renderer"
        echo "10002 user      20   0  123456  54321  12345 S   5.0   2.0   0:30.00 cursor --type=gpu-process"
        echo "10003 user      20   0  123456  54321  12345 S   1.0   1.0   0:10.00 cursor --type=utility"
    fi
    return 0
}

# Mock sleep to do nothing
sleep() {
    return 0
}

# Mock read to exit after one iteration
read() {
    return 1
}

# Export functions
export -f ps
export -f mock_pgrep
export -f mock_free
export -f pgrep
export -f free
export -f top
export -f sleep
export -f read
EOF
    
    # Make the script executable
    chmod +x "${TEMP_SCRIPT}"
    
    echo "${TEMP_SCRIPT}"
}

# Test process monitoring
test_process_monitoring() {
    local test_script=$(create_test_script)
    local output_file="${MOCK_HOME}/monitor_output.log"
    
    # Run the script with detailed output
    echo "Running script and capturing output to ${output_file}"
    bash "${test_script}" > "${output_file}" 2>&1
    
    # Debug - show the output
    echo "Script output:"
    cat "${output_file}"
    
    # Check if it detected Cursor processes (case insensitive search)
    if grep -i "cursor.*renderer" "${output_file}"; then
        echo "Process monitoring: PASSED - detected Cursor renderer process"
    else
        echo "Process monitoring: FAILED - didn't detect Cursor processes"
        return 1
    fi
    
    # Check if it shows CPU usage
    if grep -q "%CPU" "${output_file}"; then
        echo "CPU usage display: PASSED"
    else
        echo "CPU usage display: FAILED - didn't show CPU usage"
        return 1
    fi
    
    # Check if it shows memory usage
    if grep -q "MiB Mem" "${output_file}" || grep -q "%MEM" "${output_file}"; then
        echo "Memory usage display: PASSED"
    else
        echo "Memory usage display: FAILED - didn't show memory usage"
        return 1
    fi
    
    # Clean up
    rm -f "${test_script}"
    
    return 0
}

# Run all tests
run_tests() {
    test_setup
    
    local failed=0
    
    # Test process monitoring
    echo "Testing process monitoring..."
    if ! test_process_monitoring; then
        failed=$((failed + 1))
    fi
    
    return $failed
}

# Execute tests
run_tests
exit $? 