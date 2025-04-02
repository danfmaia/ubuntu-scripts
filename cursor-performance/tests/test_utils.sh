#!/bin/bash

# Test utilities for Cursor performance scripts tests
# Common functions and helpers for test scripts

# Ensure we're in test mode
if [[ "$TEST_MODE" != "1" ]]; then
    echo "Error: This script should only be sourced by test scripts"
    exit 1
fi

# Mock process execution
mock_process() {
    local process_name="$1"
    local count="$2"
    
    # Create a file to indicate process is mocked
    mkdir -p "${MOCK_HOME}/processes"
    echo "$count" > "${MOCK_HOME}/processes/${process_name}"
}

# Mock command to simulate pgrep for testing
mock_pgrep() {
    local process="$1"
    local mock_file="${MOCK_HOME}/processes/${process}"
    
    if [[ -f "$mock_file" ]]; then
        # Generate dummy PIDs based on count
        local count=$(cat "$mock_file")
        for i in $(seq 1 $count); do
            echo $((10000 + i))
        done
        return 0
    fi
    
    return 1
}

# Mock command to simulate du command
mock_du() {
    echo "100M	${MOCK_HOME}/config/Cursor/CachedData"
}

# Mock free command output
mock_free() {
    echo "               total        used        free      shared  buff/cache   available"
    echo "Mem:       16285956     8155468     1273844      700772     6856644     7127824"
    echo "Swap:       2097148      382852     1714296"
}

# Capture command output
capture_output() {
    "$@" > "${MOCK_HOME}/cmd_output" 2>&1
    return $?
}

# Assert expected output
assert_output_contains() {
    local expected="$1"
    
    if grep -q "$expected" "${MOCK_HOME}/cmd_output"; then
        return 0
    else
        echo "Expected output to contain: $expected"
        echo "Actual output:"
        cat "${MOCK_HOME}/cmd_output"
        return 1
    fi
}

# Assert file exists
assert_file_exists() {
    local file="$1"
    
    if [[ -f "$file" ]]; then
        return 0
    else
        echo "Expected file to exist: $file"
        return 1
    fi
}

# Assert directory exists
assert_dir_exists() {
    local dir="$1"
    
    if [[ -d "$dir" ]]; then
        return 0
    else
        echo "Expected directory to exist: $dir"
        return 1
    fi
}

# Assert file contains
assert_file_contains() {
    local file="$1"
    local content="$2"
    
    if grep -q "$content" "$file"; then
        return 0
    else
        echo "Expected file $file to contain: $content"
        echo "Actual content:"
        cat "$file"
        return 1
    fi
}

# Create mock settings file
create_mock_settings() {
    local file="${MOCK_HOME}/config/Cursor/User/settings.json"
    local content="$1"
    
    mkdir -p "$(dirname "$file")"
    echo "$content" > "$file"
}

# Override potentially harmful commands for safe testing
override_harmful_commands() {
    # Override xdg-open to prevent files from opening
    function xdg-open() {
        echo "SAFE TEST: Would have opened: $*"
        return 0
    }
    
    # Override code/VS Code to prevent windows from opening
    function code() {
        echo "SAFE TEST: Would have opened in code: $*"
        return 0
    }
    
    # Export these functions
    export -f xdg-open
    export -f code
}

# Call the safety overrides - this ensures VS Code windows won't open even if tests fail
override_harmful_commands

# Export mock commands for tests
export -f mock_pgrep
export -f mock_du
export -f mock_free
export -f assert_output_contains
export -f assert_file_exists
export -f assert_dir_exists
export -f assert_file_contains 