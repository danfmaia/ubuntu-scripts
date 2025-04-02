#!/bin/bash

# Test for cursor-performance-dashboard.sh
# Tests the performance dashboard script using a mock environment

# Load test utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/test_utils.sh"

# Set up mock environment
test_setup() {
    # Create mock directories
    mkdir -p "${MOCK_HOME}/config/Cursor/CachedData"
    mkdir -p "${MOCK_HOME}/.cursor/extensions"
    mkdir -p "${MOCK_HOME}/processes"
    
    # Create mock cached data
    dd if=/dev/zero of="${MOCK_HOME}/config/Cursor/CachedData/test.bin" bs=1M count=5 2>/dev/null
    
    # Mock processes
    echo "3" > "${MOCK_HOME}/processes/cursor"
}

# Create a temporary script with modifications for testing
create_dashboard_test_script() {
    local TEMP_SCRIPT="${SCRIPT_DIR}/temp_dashboard_script.sh"
    
    # Read the dashboard script
    cat "${PERF_SCRIPTS_DIR}/cursor-performance-dashboard.sh" > "${TEMP_SCRIPT}"
    
    # Replace paths
    sed -i "s|~|${MOCK_HOME}|g" "${TEMP_SCRIPT}"
    
    # Disable terminal colors
    sed -i "s|\${GREEN}||g; s|\${YELLOW}||g; s|\${RED}||g; s|\${NC}||g; s|\${BOLD}||g; s|\${BLUE}||g" "${TEMP_SCRIPT}"
    sed -i "s|echo -e|echo|g" "${TEMP_SCRIPT}"
    
    # Disable clear and replace commands that would execute scripts
    sed -i "s|clear|: # clear disabled|g" "${TEMP_SCRIPT}"
    
    # Mock the bash command to prevent actual script execution
    cat >> "${TEMP_SCRIPT}" << EOF
# Mock bash command to track would-be execution
bash() {
    if [[ "\$1" == *.sh ]]; then
        echo "WOULD_RUN: \$1"
        return 0
    else
        # Call the real bash for other uses
        command bash "\$@"
    fi
}

# Mock xdg-open command
xdg-open() {
    echo "WOULD_OPEN_WITH_XDG: \$1"
    return 0
}

# Mock code command
code() {
    echo "WOULD_OPEN_IN_CODE: \$1"
    return 0
}

# Export the mocked commands
export -f bash
export -f xdg-open
export -f code
EOF
    
    echo "${TEMP_SCRIPT}"
}

# Create a modified version of the dashboard script for testing
create_test_script() {
    # Create a temporary script with modified paths
    local TEMP_SCRIPT="${SCRIPT_DIR}/temp_dashboard_script.sh"
    
    # Read the original script
    cat "${PERF_SCRIPTS_DIR}/cursor-performance-dashboard.sh" > "${TEMP_SCRIPT}"
    
    # Replace script paths to use absolute paths to ensure they're found
    sed -i "s|bash ./.vscode/performance/cursor-monitor.sh|bash ${PERF_SCRIPTS_DIR}/cursor-monitor.sh|g" "${TEMP_SCRIPT}"
    sed -i "s|bash ./.vscode/performance/cursor-cleanup-safe.sh|bash ${PERF_SCRIPTS_DIR}/cursor-cleanup-safe.sh|g" "${TEMP_SCRIPT}"
    sed -i "s|bash ./.vscode/performance/cursor-disable-extensions.sh|bash ${PERF_SCRIPTS_DIR}/cursor-disable-extensions.sh|g" "${TEMP_SCRIPT}"
    
    # Replace guide file paths
    sed -i "s|./.vscode/performance/cursor-performance-guide.md|${PERF_SCRIPTS_DIR}/cursor-performance-guide.md|g" "${TEMP_SCRIPT}"
    sed -i "s|./.vscode/performance/cursor-extension-management.md|${PERF_SCRIPTS_DIR}/cursor-extension-management.md|g" "${TEMP_SCRIPT}"
    
    # Replace paths and commands
    sed -i "s|~|${MOCK_HOME}|g" "${TEMP_SCRIPT}"
    sed -i "s|\${GREEN}||g; s|\${YELLOW}||g; s|\${RED}||g; s|\${NC}||g; s|\${BOLD}||g; s|\${BLUE}||g" "${TEMP_SCRIPT}"
    sed -i "s|echo -e|echo|g" "${TEMP_SCRIPT}"
    
    # Disable clear command and interactive prompts
    sed -i "s|clear|: # clear disabled|g" "${TEMP_SCRIPT}"
    
    # Override functions using test mocks
    cat >> "${TEMP_SCRIPT}" << EOF
# Force use of mocked environment only
if [[ "\${MOCK_HOME}" == "" ]]; then
    echo "ERROR: MOCK_HOME environment variable not set. Cannot run test safely."
    exit 1
fi

# Mock pgrep for testing
pgrep() {
    mock_pgrep "\$@"
}

# Mock free for testing
free() {
    mock_free "\$@"
}

# Mock du for testing
du() {
    mock_du "\$@"
}

# Mock top for testing - prevent real system monitoring
top() {
    echo "MOCK: Would have executed top"
    echo "top - 10:00:00 up 1 day, 2:00, 1 user, load average: 0.50, 0.60, 0.70"
    echo "Tasks: 100 total, 1 running, 99 sleeping, 0 stopped, 0 zombie"
    echo "%Cpu(s): 10.0 us, 5.0 sy, 0.0 ni, 85.0 id, 0.0 wa, 0.0 hi, 0.0 si, 0.0 st"
    echo "MiB Mem : 16000.0 total, 8000.0 free, 6000.0 used, 2000.0 buff/cache"
    return 0
}

# Mock ps for testing - prevent real process listing
ps() {
    echo "MOCK: Would have executed ps"
    echo "USER        PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND"
    echo "user      10001  25.0  2.0 123456 54321 ?        Sl   10:00   1:30 /usr/bin/cursor --type=renderer"
    echo "user      10002   5.0  1.0 123456 54321 ?        Sl   10:00   0:30 /usr/bin/cursor --type=gpu-process"
    return 0
}

# Mock bash execution - prevent ANY script execution
bash() {
    # Instead of running scripts, just echo which script would be run
    echo "WOULD_RUN: \$@"
    return 0
}

# Mock code command to prevent actual VS Code windows from opening
code() {
    # Just log what would be opened without actually opening it
    echo "WOULD_OPEN_IN_CODE: \$@"
    return 0
}

# Mock xdg-open command to prevent actual files from opening
xdg-open() {
    # Just log what would be opened without actually opening it
    echo "WOULD_OPEN_WITH_XDG: \$@"
    return 0
}

# Override command execution check
command() {
    if [[ "\$1" == "-v" && "\$2" == "xdg-open" ]]; then
        return 0  # Pretend xdg-open IS available for testing menu option 4 & 5
    elif [[ "\$1" == "-v" && "\$2" == "code" ]]; then
        return 0  # Pretend code IS available for testing menu option 6
    fi
    return 0
}

# Override pgrep to ensure we get controlled results
pgrep() {
    if [[ "\$1" == "-f" && "\$2" == "cursor" ]]; then
        # Return 3 processes for cursor
        echo "10001"
        echo "10002"
        echo "10003"
        return 0
    elif [[ "\$1" == "-x" && "\$2" == "cursor" ]]; then
        # This is the check for "cursor is running" - use process file
        if [[ -f "${MOCK_HOME}/processes/cursor" ]]; then
            cat "${MOCK_HOME}/processes/cursor" | while read -r line; do
                echo "$((10000 + line))"
            done
            return 0
        else
            return 1
        fi
    fi
    return 1
}

# Export functions
export -f mock_pgrep
export -f mock_free
export -f mock_du
export -f pgrep
export -f free
export -f du
export -f ps
export -f top
export -f bash
export -f code
export -f xdg-open
export -f command
EOF
    
    # Make the script executable
    chmod +x "${TEMP_SCRIPT}"
    
    echo "${TEMP_SCRIPT}"
}

# Test each menu option in the dashboard
test_dashboard_option() {
    local option=$1
    local output_file="${MOCK_HOME}/output_${option}.log"
    local passed=0
    local failed=0
    
    echo "Testing dashboard option: ${option}"
    
    # Create modified script for this option
    local option_script=$(create_dashboard_test_script)
    
    case $option in
        4|5|6)
            # For options that open files/editors, auto-confirm with 'y'
            sed -i "s|read -r choice|choice=${option}|g" "${option_script}"
            sed -i "s|read -r confirm|confirm=y|g" "${option_script}"
            ;;
        *)
            # For other options, just select the option
            sed -i "s|read -r choice|choice=${option}|g" "${option_script}"
            ;;
    esac
    
    # Run the script
    bash "${option_script}" > "${output_file}" 2>&1
    
    case $option in
        1)
            # Should run the monitor script
            if grep -q "WOULD_RUN: ${PERF_SCRIPTS_DIR}/cursor-monitor.sh" "${output_file}"; then
                echo "Option ${option}: PASSED"
                passed=$((passed + 1))
            else
                echo "Option ${option}: FAILED - didn't try to run monitor script"
                cat "${output_file}"
                failed=$((failed + 1))
            fi
            ;;
        2)
            # Should run the cleanup script
            if grep -q "WOULD_RUN: ${PERF_SCRIPTS_DIR}/cursor-cleanup-safe.sh" "${output_file}"; then
                echo "Option ${option}: PASSED"
                passed=$((passed + 1))
            else
                echo "Option ${option}: FAILED - didn't try to run cleanup script"
                cat "${output_file}"
                failed=$((failed + 1))
            fi
            ;;
        3)
            # Should run the extension manager
            if grep -q "WOULD_RUN: ${PERF_SCRIPTS_DIR}/cursor-disable-extensions.sh" "${output_file}"; then
                echo "Option ${option}: PASSED"
                passed=$((passed + 1))
            else
                echo "Option ${option}: FAILED - didn't try to run extension manager"
                cat "${output_file}"
                failed=$((failed + 1))
            fi
            ;;
        4)
            # Should try to open performance guide
            if grep -q "WOULD_OPEN_WITH_XDG" "${output_file}" && 
               grep -q "cursor-performance-guide.md" "${output_file}"; then
                echo "Option ${option}: PASSED"
                passed=$((passed + 1))
            else
                echo "Option ${option}: FAILED - didn't handle performance guide"
                cat "${output_file}"
                failed=$((failed + 1))
            fi
            ;;
        5)
            # Should try to open extension management guide
            if grep -q "WOULD_OPEN_WITH_XDG" "${output_file}" && 
               grep -q "cursor-extension-management.md" "${output_file}"; then
                echo "Option ${option}: PASSED"
                passed=$((passed + 1))
            else
                echo "Option ${option}: FAILED - didn't handle extension guide"
                failed=$((failed + 1))
            fi
            ;;
        6)
            # Should try to open settings files
            if grep -q "WOULD_OPEN_IN_CODE" "${output_file}" && 
               grep -q "settings.json" "${output_file}"; then
                echo "Option ${option}: PASSED"
                passed=$((passed + 1))
            else
                echo "Option ${option}: FAILED - didn't handle settings"
                failed=$((failed + 1))
            fi
            ;;
        7)
            # Should exit
            if grep -q "Exiting dashboard" "${output_file}"; then
                echo "Option ${option}: PASSED"
                passed=$((passed + 1))
            else
                echo "Option ${option}: FAILED - didn't handle exit"
                failed=$((failed + 1))
            fi
            ;;
    esac
    
    # Clean up
    rm -f "${option_script}"
    
    # Report results
    echo "Menu option tests: ${passed} passed, ${failed} failed"
    
    # Return success if all tests passed
    return $failed
}

# Test process detection
test_process_detection() {
    # Setup - create a script with cursor processes mocked
    local test_script=$(create_dashboard_test_script)
    local output_file="${MOCK_HOME}/process_detection.log"
    
    # Add cursor process mock
    echo "3" > "${MOCK_HOME}/processes/cursor"
    
    # Add mock pgrep function to detect cursor
    cat >> "${test_script}" << EOF
# Mock pgrep to return a match for cursor
pgrep() {
    if [[ "\$1" == "-x" && "\$2" == "cursor" ]]; then
        # Return PIDs to simulate cursor running
        echo "12345"
        return 0
    fi
    return 1
}
export -f pgrep
EOF
    
    # Run the script and exit immediately
    sed -i "s|read -r choice|choice=7|g" "${test_script}"
    bash "${test_script}" > "${output_file}" 2>&1
    
    # Check if cursor was detected as running
    if grep -q "Cursor is currently running" "${output_file}"; then
        echo "Process detection: PASSED - Cursor detected as running"
        return 0
    else
        echo "Process detection: FAILED - Cursor not detected as running"
        cat "${output_file}"
        return 1
    fi
}

# Test cache detection
test_cache_detection() {
    # Set up a script with large cache mocked
    local test_script=$(create_dashboard_test_script)
    local output_file="${MOCK_HOME}/cache_detection.log"
    
    # Create a large cache directory
    mkdir -p "${MOCK_HOME}/config/Cursor/CachedData"
    dd if=/dev/zero of="${MOCK_HOME}/config/Cursor/CachedData/large_cache.bin" bs=1M count=200 2>/dev/null
    
    # Add mock du command to report a large cache
    cat >> "${test_script}" << EOF
# Mock du to report large cache
du() {
    if [[ "\$@" == *"CachedData"* ]]; then
        echo "1.5G${MOCK_HOME}/config/Cursor/CachedData"
        return 0
    fi
    # Fall back to real du for other paths
    command du "\$@"
}
export -f du
EOF
    
    # Run the script and exit immediately
    sed -i "s|read -r choice|choice=7|g" "${test_script}"
    bash "${test_script}" > "${output_file}" 2>&1
    
    # Check if large cache was detected
    if grep -q "Large cache detected" "${output_file}"; then
        echo "Cache detection: PASSED - Large cache detected"
        return 0
    else
        echo "Cache detection: FAILED - Large cache not detected"
        cat "${output_file}"
        return 1
    fi
}

# Run all tests
run_tests() {
    test_setup
    
    local failed=0
    
    # Test menu options
    echo "Testing menu options..."
    for option in {1..7}; do
        if ! test_dashboard_option "${option}"; then
            failed=$((failed + 1))
        fi
    done
    
    # Test process detection
    echo "Testing process detection..."
    if ! test_process_detection; then
        failed=$((failed + 1))
    fi
    
    # Test cache detection
    echo "Testing cache detection..."
    if ! test_cache_detection; then
        failed=$((failed + 1))
    fi
    
    return $failed
}

# Execute tests
run_tests
exit $? 