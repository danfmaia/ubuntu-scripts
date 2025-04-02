#!/bin/bash

# Test for cursor-disable-extensions.sh
# Tests the extension manager script using a mock environment

# Load test utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/test_utils.sh"

# Set up mock environment
test_setup() {
    # Create mock extensions directory
    mkdir -p "${MOCK_HOME}/.cursor/extensions"
    
    # Create some mock extension folders
    for ext in "ms-python.python" "ms-python.vscode-pylance" "userext1.extension" "userext2.extension"; do
        mkdir -p "${MOCK_HOME}/.cursor/extensions/${ext}"
        echo "Mock extension" > "${MOCK_HOME}/.cursor/extensions/${ext}/package.json"
    done
}

# Create a modified version of the extension manager script for testing
create_test_script() {
    # Create a temporary script with modified paths
    local TEMP_SCRIPT="${SCRIPT_DIR}/temp_extension_manager.sh"
    
    # Read the original script
    cat "${PERF_SCRIPTS_DIR}/cursor-disable-extensions.sh" > "${TEMP_SCRIPT}"
    
    # Replace paths and commands
    sed -i "s|~|${MOCK_HOME}|g" "${TEMP_SCRIPT}"
    sed -i "s|\${GREEN}||g; s|\${YELLOW}||g; s|\${RED}||g; s|\${NC}||g; s|\${BOLD}||g; s|\${BLUE}||g" "${TEMP_SCRIPT}"
    sed -i "s|echo -e|echo|g" "${TEMP_SCRIPT}"
    
    # Disable clear command and any interactive prompts
    sed -i "s|clear|: # clear disabled|g" "${TEMP_SCRIPT}"
    
    # Replace the code CLI with a mock version
    cat >> "${TEMP_SCRIPT}" << EOF
# Mock code CLI for testing
code() {
    local cmd="\$1"
    shift
    
    case "\$cmd" in
        "--list-extensions")
            # List the extensions in the mock directory
            echo "ms-python.python"
            echo "ms-python.vscode-pylance"
            echo "userext1.extension"
            echo "userext2.extension"
            ;;
        "--disable-extension")
            # Mark the extension as disabled
            local ext="\$1"
            echo "MOCK: Disabling extension \$ext"
            touch "${MOCK_HOME}/.cursor/extensions/\${ext}.disabled"
            ;;
        "--enable-extension")
            # Mark the extension as enabled
            local ext="\$1"
            echo "MOCK: Enabling extension \$ext"
            rm -f "${MOCK_HOME}/.cursor/extensions/\${ext}.disabled" 2>/dev/null
            ;;
        "--disable-extensions")
            # Disable all extensions
            echo "MOCK: Disabling all extensions"
            for ext in ms-python.python ms-python.vscode-pylance userext1.extension userext2.extension; do
                touch "${MOCK_HOME}/.cursor/extensions/\${ext}.disabled"
            done
            ;;
        *)
            echo "MOCK: Would have run code command: \$cmd \$@"
            return 0
            ;;
    esac
    
    return 0
}

# Override spinner function to do nothing
spinner() {
    : # Do nothing
}

# Export the functions
export -f code
export -f spinner
EOF
    
    # Make the script executable
    chmod +x "${TEMP_SCRIPT}"
    
    echo "${TEMP_SCRIPT}"
}

# Test case 1: List extensions
test_list_extensions() {
    local test_script=$(create_test_script)
    
    # Modify to auto-select option 3 (list extensions)
    sed -i "s|read -r choice|choice=3|g" "${test_script}"
    
    # Run the modified script and capture output
    bash "${test_script}" > "${MOCK_HOME}/cmd_output" 2>&1
    
    # Check if all extensions are listed
    if ! grep -q "ms-python.python" "${MOCK_HOME}/cmd_output"; then
        echo "Test failed: Extension listing doesn't contain expected extension"
        cat "${MOCK_HOME}/cmd_output"
        return 1
    fi
    
    return 0
}

# Test case 2: Disable non-essential extensions
test_disable_nonessential() {
    local test_script=$(create_test_script)
    
    # Modify to auto-select option 1 (disable non-essential)
    sed -i "s|read -r choice|choice=1|g" "${test_script}"
    
    # Run the modified script
    bash "${test_script}" > /dev/null
    
    # Essential extensions should not be disabled
    if [[ -f "${MOCK_HOME}/.cursor/extensions/ms-python.python.disabled" ]]; then
        echo "Test failed: Essential extension was disabled"
        return 1
    fi
    
    # Non-essential extension should be disabled
    if [[ ! -f "${MOCK_HOME}/.cursor/extensions/userext1.extension.disabled" ]]; then
        echo "Test failed: Non-essential extension was not disabled"
        return 1
    fi
    
    return 0
}

# Test case 3: Enable only essential extensions
test_enable_only_essential() {
    local test_script=$(create_test_script)
    
    # Modify to auto-select option 2 (enable only essential)
    sed -i "s|read -r choice|choice=2|g" "${test_script}"
    
    # Run the modified script
    bash "${test_script}" > /dev/null
    
    # Check if essential extensions are enabled
    if [[ -f "${MOCK_HOME}/.cursor/extensions/ms-python.python.disabled" ]]; then
        echo "Test failed: Essential extension was disabled"
        return 1
    fi
    
    # Check if essential extensions are enabled
    if [[ -f "${MOCK_HOME}/.cursor/extensions/ms-python.vscode-pylance.disabled" ]]; then
        echo "Test failed: Essential extension was disabled"
        return 1
    fi
    
    return 0
}

# Run all tests
run_tests() {
    test_setup
    
    local failed=0
    
    echo "Running test: List extensions"
    if ! test_list_extensions; then
        ((failed++))
    fi
    
    echo "Running test: Disable non-essential extensions"
    if ! test_disable_nonessential; then
        ((failed++))
    fi
    
    echo "Running test: Enable only essential extensions"
    if ! test_enable_only_essential; then
        ((failed++))
    fi
    
    return $failed
}

# Execute tests
run_tests
exit $? 