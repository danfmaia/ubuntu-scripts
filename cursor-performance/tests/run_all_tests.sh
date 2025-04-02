#!/bin/bash

# Run All Tests Script
# Executes all test scripts in the test suite and reports overall results

# Set colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Running all Cursor Performance Toolkit tests...${NC}"
echo

# Track overall success
TESTS_PASSED=0
TESTS_FAILED=0
FAILED_TESTS=()

# Function to run a test and track results
run_test() {
    local test_script="$1"
    local test_name="$2"
    
    echo -e "${YELLOW}Running test: ${test_name}${NC}"
    
    # Run the test script
    bash "$test_script"
    local result=$?
    
    if [ $result -eq 0 ]; then
        echo -e "${GREEN}✓ ${test_name} passed${NC}"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}✗ ${test_name} failed${NC}"
        ((TESTS_FAILED++))
        FAILED_TESTS+=("$test_name")
    fi
    echo
}

# Run each test script
run_test "test_cleanup_script.sh" "Cache Cleanup Script"
run_test "test_extension_manager.sh" "Extension Manager"
run_test "test_performance_dashboard.sh" "Performance Dashboard"
run_test "test_monitor.sh" "Performance Monitor"

# Print summary
echo -e "${YELLOW}Test Summary:${NC}"
echo -e "${GREEN}Tests passed: ${TESTS_PASSED}${NC}"
if [ $TESTS_FAILED -gt 0 ]; then
    echo -e "${RED}Tests failed: ${TESTS_FAILED}${NC}"
    echo -e "${RED}Failed tests:${NC}"
    for test in "${FAILED_TESTS[@]}"; do
        echo -e "${RED}- ${test}${NC}"
    done
    exit 1
else
    echo -e "${GREEN}All tests passed!${NC}"
    
    # Run coverage analysis if all tests pass
    echo
    echo -e "${YELLOW}Running coverage analysis...${NC}"
    bash coverage_tracker.sh
fi

exit 0 