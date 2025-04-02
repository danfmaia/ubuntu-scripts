#!/bin/bash

# Cursor Performance Scripts Test Runner
# Run all tests for performance optimization scripts

# Terminal colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Test directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TESTS_DIR="${SCRIPT_DIR}"
PERF_DIR="$(dirname "${SCRIPT_DIR}")"

# Track test results
PASSED=0
FAILED=0
SKIPPED=0

# Display banner
echo -e "${BOLD}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║            ${BLUE}CURSOR PERFORMANCE SCRIPTS TEST SUITE${NC}            ${BOLD}║${NC}"
echo -e "${BOLD}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Create test environment
create_test_env() {
    echo -e "${YELLOW}Creating test environment...${NC}"
    # Create mock directories and files for testing
    mkdir -p "${TESTS_DIR}/mocks/config/Cursor/CachedData"
    mkdir -p "${TESTS_DIR}/mocks/config/Cursor/User"
    mkdir -p "${TESTS_DIR}/mocks/cursor/extensions"
    
    # Create mock settings file
    echo '{
      "editor.cursorSmoothCaretAnimation": "on",
      "editor.smoothScrolling": true
    }' > "${TESTS_DIR}/mocks/config/Cursor/User/settings.json"
    
    # Create mock cached data
    dd if=/dev/zero of="${TESTS_DIR}/mocks/config/Cursor/CachedData/mockCache.bin" bs=1M count=10 2>/dev/null
    
    echo -e "${GREEN}Test environment created.${NC}"
}

# Clean up test environment
cleanup_test_env() {
    echo -e "${YELLOW}Cleaning up test environment...${NC}"
    rm -rf "${TESTS_DIR}/mocks"
    echo -e "${GREEN}Test environment cleaned up.${NC}"
}

# Run a single test file
run_test() {
    local test_file="$1"
    local test_name=$(basename "$test_file" .sh)
    
    echo -e "\n${BLUE}Running test: ${test_name}${NC}"
    
    # Check if test should be skipped in certain environments
    if [[ -f "${test_file}.skip" ]]; then
        echo -e "${YELLOW}SKIPPED${NC}: Test $test_name (see .skip file for reason)"
        ((SKIPPED++))
        return
    fi
    
    # Run the test with mock environment variables
    TEST_MODE=1 \
    MOCK_HOME="${TESTS_DIR}/mocks" \
    PERF_SCRIPTS_DIR="${PERF_DIR}" \
    bash "$test_file"
    
    # Check result
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}PASSED${NC}: Test $test_name"
        ((PASSED++))
    else
        echo -e "${RED}FAILED${NC}: Test $test_name"
        ((FAILED++))
    fi
}

# Main test execution
main() {
    # Setup
    create_test_env
    
    # Find and run all test_*.sh files
    echo -e "\n${BOLD}Running tests...${NC}"
    for test_file in "${TESTS_DIR}"/test_*.sh; do
        if [ -f "$test_file" ]; then
            run_test "$test_file"
        fi
    done
    
    # Display summary
    echo -e "\n${BOLD}Test Summary:${NC}"
    echo -e "${GREEN}Passed: $PASSED${NC}"
    echo -e "${RED}Failed: $FAILED${NC}"
    echo -e "${YELLOW}Skipped: $SKIPPED${NC}"
    echo -e "Total: $((PASSED + FAILED + SKIPPED))"
    
    # Cleanup
    cleanup_test_env
    
    # Return appropriate exit code
    if [ $FAILED -eq 0 ]; then
        return 0
    else
        return 1
    fi
}

# Run tests
main
exit $? 