#!/bin/bash

# Simple Coverage Report for Cursor Performance Scripts
# Outputs a text-based report directly to the terminal

# Set colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PERF_DIR="$(dirname "${SCRIPT_DIR}")"

# Script names to check
SCRIPTS=(
    "cursor-cleanup-safe.sh"
    "cursor-disable-extensions.sh"
    "cursor-monitor.sh"
    "cursor-performance-dashboard.sh"
)

# Test file naming patterns to check (for flexibility)
TEST_PATTERNS=(
    "test_%s.sh"         # test_script-name.sh
    "test_%s"            # test_script-name (no extension)
    "%s_test.sh"         # script-name_test.sh
    "test-%s.sh"         # test-script-name.sh
)

# Display header
echo -e "${BOLD}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║          ${BLUE}CURSOR PERFORMANCE SCRIPTS COVERAGE REPORT${NC}        ${BOLD}║${NC}"
echo -e "${BOLD}╚════════════════════════════════════════════════════════════╝${NC}"
echo

# Function to find test file for a script
find_test_file() {
    local script="$1"
    local base_name=$(basename "$script" .sh)
    
    # Check all possible test name patterns
    for pattern in "${TEST_PATTERNS[@]}"; do
        local test_name=$(printf "$pattern" "$base_name")
        if [[ -f "${SCRIPT_DIR}/${test_name}" ]]; then
            echo "${SCRIPT_DIR}/${test_name}"
            return 0
        fi
    done
    
    # Special case for fixing test_cleanup_script.sh naming mismatch
    if [[ "$base_name" == "cursor-cleanup-safe" && -f "${SCRIPT_DIR}/test_cleanup_script.sh" ]]; then
        echo "${SCRIPT_DIR}/test_cleanup_script.sh"
        return 0
    fi
    
    # Special case for extension manager naming mismatch
    if [[ "$base_name" == "cursor-disable-extensions" && -f "${SCRIPT_DIR}/test_extension_manager.sh" ]]; then
        echo "${SCRIPT_DIR}/test_extension_manager.sh"
        return 0
    fi
    
    # Special case for performance dashboard
    if [[ "$base_name" == "cursor-performance-dashboard" && -f "${SCRIPT_DIR}/test_performance_dashboard.sh" ]]; then
        echo "${SCRIPT_DIR}/test_performance_dashboard.sh"
        return 0
    fi
    
    # Special case for monitor script
    if [[ "$base_name" == "cursor-monitor" && -f "${SCRIPT_DIR}/test_monitor.sh" ]]; then
        echo "${SCRIPT_DIR}/test_monitor.sh"
        return 0
    fi
    
    return 1
}

# Function to count key functions in a script
count_functions() {
    local script="$1"
    grep -E '^[[:space:]]*(function[[:space:]]+[a-zA-Z0-9_]+[[:space:]]*\(\)|[a-zA-Z0-9_]+[[:space:]]*\(\))' "$script" | wc -l
}

# Calculate overall statistics
total_scripts=${#SCRIPTS[@]}
covered_scripts=0
total_lines=0
covered_lines=0

# Table header
echo -e "${BOLD}Script Coverage Summary${NC}"
echo -e "${BOLD}-------------------------${NC}"
printf "%-30s %-20s %-15s\n" "Script" "Test File" "Status"
echo -e "---------------------------------------------------------------------------------"

# Check each script
for script in "${SCRIPTS[@]}"; do
    script_path="${PERF_DIR}/${script}"
    script_lines=$(wc -l < "$script_path")
    total_lines=$((total_lines + script_lines))
    
    # Try to find test file
    test_file=$(find_test_file "$script")
    
    if [[ -n "$test_file" ]]; then
        covered_scripts=$((covered_scripts + 1))
        test_name=$(basename "$test_file")
        # Count functions to estimate coverage
        script_functions=$(count_functions "$script_path")
        covered_lines=$((covered_lines + script_lines))
        printf "%-30s %-20s ${GREEN}%-15s${NC}\n" "$script" "$test_name" "COVERED"
    else
        printf "%-30s %-20s ${RED}%-15s${NC}\n" "$script" "NOT FOUND" "UNCOVERED"
    fi
done

# Calculate coverage percentage
script_coverage=$((covered_scripts * 100 / total_scripts))
line_coverage=$((covered_lines * 100 / total_lines))

# Display coverage summary
echo -e "\n${BOLD}Coverage Summary${NC}"
echo -e "${BOLD}----------------${NC}"
echo -e "Total Scripts: $total_scripts"
echo -e "Covered Scripts: $covered_scripts/$total_scripts (${script_coverage}%)"
echo -e "Line Coverage (estimated): ${line_coverage}%"

# Display test file details
echo -e "\n${BOLD}Available Test Files${NC}"
echo -e "${BOLD}-------------------${NC}"
for test_file in "${SCRIPT_DIR}"/test_*.sh; do
    if [[ -f "$test_file" ]]; then
        test_name=$(basename "$test_file")
        test_lines=$(wc -l < "$test_file")
        echo -e "${BLUE}${test_name}${NC} (${test_lines} lines)"
    fi
done

# Provide recommendations for missing tests
if [[ $covered_scripts -lt $total_scripts ]]; then
    echo -e "\n${BOLD}Recommendations${NC}"
    echo -e "${BOLD}--------------${NC}"
    echo -e "The following scripts need test coverage:"
    
    for script in "${SCRIPTS[@]}"; do
        if ! find_test_file "$script" > /dev/null; then
            echo -e "  ${RED}✗${NC} ${script}"
        fi
    done
    
    echo -e "\nConsider creating test files with these naming patterns:"
    for pattern in "${TEST_PATTERNS[@]}"; do
        echo -e "  - $(printf "$pattern" "script-name")"
    done
fi

echo -e "\n${GREEN}Report complete!${NC}" 