#!/bin/bash

# Test for cursor-cleanup-safe.sh
# Tests the cleanup script using a mock environment

# Load test utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/test_utils.sh"

# Set up mock environment
test_setup() {
    # Create mock cache directory with test files
    mkdir -p "${MOCK_HOME}/config/Cursor/CachedData"
    mkdir -p "${MOCK_HOME}/config/Cursor/Code Cache"
    mkdir -p "${MOCK_HOME}/config/Cursor/GPUCache"
    mkdir -p "${MOCK_HOME}/config/Cursor/User/workspaceStorage"
    mkdir -p "${MOCK_HOME}/config/Cursor/logs"
    mkdir -p "${MOCK_HOME}/config/Cursor/Crashpad/completed"
    mkdir -p "${MOCK_HOME}/.cursor_backup"
    mkdir -p "${MOCK_HOME}/.cursor/extensions"
    
    # Create test files
    dd if=/dev/zero of="${MOCK_HOME}/config/Cursor/CachedData/test1.bin" bs=1M count=5 2>/dev/null
    dd if=/dev/zero of="${MOCK_HOME}/config/Cursor/Code Cache/test2.bin" bs=1M count=5 2>/dev/null
    dd if=/dev/zero of="${MOCK_HOME}/config/Cursor/GPUCache/test3.bin" bs=1M count=5 2>/dev/null
    dd if=/dev/zero of="${MOCK_HOME}/config/Cursor/logs/cursor.log" bs=1K count=10 2>/dev/null
    dd if=/dev/zero of="${MOCK_HOME}/config/Cursor/Crashpad/completed/crash1.dmp" bs=1K count=10 2>/dev/null
    
    # Create test workspaces (create 5 for testing cleanup of older ones)
    for i in {1..5}; do
        mkdir -p "${MOCK_HOME}/config/Cursor/User/workspaceStorage/workspace_$i"
        touch "${MOCK_HOME}/config/Cursor/User/workspaceStorage/workspace_$i/timestamp_$i"
    done
    
    # Create settings file to test backup functionality
    echo '{
      "test": "value"
    }' > "${MOCK_HOME}/config/Cursor/User/settings.json"
    
    # Create mock argv.json file
    echo '{
      "enable-crash-reporter": true,
      "enable-proposed-api": ["cursor.webviews"]
    }' > "${MOCK_HOME}/config/Cursor/argv.json"
}

# Create a modified version of the cleanup script for testing
create_test_script() {
    # Create a temporary script with modified paths
    local TEMP_SCRIPT="${SCRIPT_DIR}/temp_cleanup_script.sh"
    
    # Read the original script
    cat "${PERF_SCRIPTS_DIR}/cursor-cleanup-safe.sh" > "${TEMP_SCRIPT}"
    
    # Replace paths correctly using pipe delimiter to avoid issues with slashes
    sed -i "s|~/.config/Cursor|${MOCK_HOME}/config/Cursor|g" "${TEMP_SCRIPT}"
    sed -i "s|~/.cursor|${MOCK_HOME}/.cursor|g" "${TEMP_SCRIPT}"
    sed -i "s|~/.cursor_backup|${MOCK_HOME}/.cursor_backup|g" "${TEMP_SCRIPT}"
    
    # Add debug for backup command
    sed -i "s|cp ~/.config/Cursor/User/settings.json ~/.cursor_backup/settings.json.bak-\$(date +%Y%m%d)|echo \"Debug: Running backup command\"; cp ${MOCK_HOME}/config/Cursor/User/settings.json ${MOCK_HOME}/.cursor_backup/settings.json.bak-\$(date +%Y%m%d); echo \"Debug: Backup command completed\"|g" "${TEMP_SCRIPT}"
    
    # Disable terminal colors
    sed -i "s|\${GREEN}||g; s|\${YELLOW}||g; s|\${RED}||g; s|\${NC}||g; s|\${BOLD}||g; s|\${BLUE}||g" "${TEMP_SCRIPT}"
    sed -i "s|echo -e|echo|g" "${TEMP_SCRIPT}"
    
    # Disable clear command and any interactive prompts
    sed -i "s|clear|: # clear disabled|g" "${TEMP_SCRIPT}"
    sed -i "s|read -r choice|choice=y|g" "${TEMP_SCRIPT}"
    sed -i "s|read$|: # disabled read|g" "${TEMP_SCRIPT}"
    sed -i "s|read |: # disabled read command|g" "${TEMP_SCRIPT}"
    
    # Rather than trying to substitute the pgrep command, let's create a wrapper script
    # that will run the cleanup script with a fake pgrep command
    
    local WRAPPER_SCRIPT="${SCRIPT_DIR}/run_cleanup_wrapper.sh"
    cat > "${WRAPPER_SCRIPT}" << EOF
#!/bin/bash

# Wrapper to override pgrep for testing
pgrep() {
    # Always return false (1) meaning not running
    return 1
}

# Export the function so it's available to child processes
export -f pgrep

# Run the actual script
bash "${TEMP_SCRIPT}"
EOF
    
    chmod +x "${WRAPPER_SCRIPT}"
    
    echo "${WRAPPER_SCRIPT}"
}

# Test the cleanup script functionality
test_cleanup_script() {
    local test_script=$(create_test_script)
    
    echo "Debug: Generated test script at ${test_script}"
    
    # Run the modified script and capture output for debugging
    echo "Debug: Running test script..."
    bash "${test_script}" > "${MOCK_HOME}/script_output.log" 2>&1
    
    # Print script output for debugging
    echo "Debug: Script output:"
    cat "${MOCK_HOME}/script_output.log"
    
    # Debug backup file existence
    echo "Debug: Contents of ${MOCK_HOME}/.cursor_backup/:"
    ls -la "${MOCK_HOME}/.cursor_backup/" || echo "Failed to list directory"
    
    # Add more debugging
    echo "Debug: Checking for backup file pattern: ${MOCK_HOME}/.cursor_backup/settings.json.bak-*"
    find "${MOCK_HOME}/.cursor_backup/" -type f -name "settings.json.bak-*" || echo "No matching files found"
    
    # When running tests within Cursor, we can't test the cache cleaning operations
    # Instead, we'll verify the operations that work while Cursor is running:
    
    # 1. Check if settings.json was backed up
    if ! ls "${MOCK_HOME}/.cursor_backup/settings.json.bak-"* > /dev/null 2>&1; then
        echo "Test failed: settings.json not backed up"
        return 1
    fi
    
    # 2. Check if settings.json still exists
    if [[ ! -s "${MOCK_HOME}/config/Cursor/User/settings.json" ]]; then
        echo "Test failed: settings.json was removed"
        return 1
    fi
    
    # 3. Check if the script detected extensions
    if ! grep -q "You have approximately" "${MOCK_HOME}/script_output.log"; then
        echo "Test failed: Extension detection not performed"
        return 1
    fi
    
    # 4. Check if memory allocation check was performed
    if ! grep -q "Checking memory allocation" "${MOCK_HOME}/script_output.log"; then
        echo "Test failed: Memory allocation check not performed"
        return 1
    fi
    
    # 5. Check if cache cleaning was performed (since our wrapper makes pgrep return false)
    if ! grep -q "GPU cache cleaned" "${MOCK_HOME}/script_output.log"; then
        echo "Test failed: GPU cache cleaning not performed"
        return 1
    fi
    
    echo "Test passed: All operations were verified"
    
    # Cleanup
    rm -f "${test_script}"
    
    return 0
}

# Run the test
run_test() {
    test_setup
    test_cleanup_script
    return $?
}

# Execute test
run_test
exit $? 