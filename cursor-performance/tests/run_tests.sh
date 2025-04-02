#!/bin/bash

# Cursor Performance Scripts Test Runner
# A unified interface for running all performance optimization toolkit tests

# Terminal colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PERF_DIR="$(dirname "${SCRIPT_DIR}")"

# Default options
USE_MOCK_ENV=true
RUN_COVERAGE=false
DETAILED_COVERAGE=false
TESTS_TO_RUN=()
VERBOSE=false
MAX_TEST_DURATION=30  # Maximum test duration in seconds
SHOW_PROGRESS=true

# Script version
VERSION="1.0.0"

# Display usage information
show_usage() {
    echo "Usage: $0 [options] [test_files]"
    echo "Options:"
    echo "  -h, --help               Show this help message"
    echo "  -v, --verbose            Show detailed test output"
    echo "  -r, --real               Run with real environment (not mock - use with caution)"
    echo "  -c, --coverage           Run simple coverage report after tests"
    echo "  -d, --detailed-coverage  Run detailed HTML coverage report after tests"
    echo "  -n, --no-execute         Safe mode that prevents executing real system commands (default)"
    echo "  -e, --execute            Allow executing real system commands (use with caution)"
    echo
    echo "Example: $0 -v test_cleanup_script.sh"
}

# Parse command line arguments
VERBOSE=0
REAL_ENV=0
COVERAGE=0
DETAILED_COVERAGE=0
NO_EXECUTE=1  # Default to safe mode
TEST_FILES=()

while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            show_usage
            exit 0
            ;;
        -v|--verbose)
            VERBOSE=1
            shift
            ;;
        -r|--real)
            REAL_ENV=1
            shift
            ;;
        -c|--coverage)
            COVERAGE=1
            shift
            ;;
        -d|--detailed-coverage)
            DETAILED_COVERAGE=1
            shift
            ;;
        -n|--no-execute)
            NO_EXECUTE=1
            shift
            ;;
        -e|--execute)
            NO_EXECUTE=0
            shift
            ;;
        -*)
            echo "Unknown option: $1"
            show_usage
            exit 1
            ;;
        *)
            TEST_FILES+=("$1")
            shift
            ;;
    esac
done

# Find all test files if none specified
find_test_files() {
    if [[ ${#TEST_FILES[@]} -eq 0 ]]; then
        for test_file in "${SCRIPT_DIR}"/test_*.sh; do
            if [[ -f "$test_file" && "$(basename "$test_file")" != "test_utils.sh" ]]; then
                TEST_FILES+=("$(basename "$test_file")")
            fi
        done
    fi
}

# Create mock environment
create_mock_env() {
    echo -e "${YELLOW}Creating mock test environment...${NC}"
    
    # Create mock directories
    mkdir -p "${SCRIPT_DIR}/mocks/config/Cursor/CachedData"
    mkdir -p "${SCRIPT_DIR}/mocks/config/Cursor/User"
    mkdir -p "${SCRIPT_DIR}/mocks/cursor/extensions"
    mkdir -p "${SCRIPT_DIR}/mocks/processes"
    
    # Create mock settings file
    echo '{
      "editor.cursorSmoothCaretAnimation": "on",
      "editor.smoothScrolling": true
    }' > "${SCRIPT_DIR}/mocks/config/Cursor/User/settings.json"
    
    # Create mock cached data
    dd if=/dev/zero of="${SCRIPT_DIR}/mocks/config/Cursor/CachedData/mockCache.bin" bs=1M count=10 2>/dev/null
    
    echo -e "${GREEN}Test environment created.${NC}"
}

# Clean up mock environment
cleanup_mock_env() {
    echo -e "${YELLOW}Cleaning up test environment...${NC}"
    rm -rf "${SCRIPT_DIR}/mocks"
    echo -e "${GREEN}Test environment cleaned up.${NC}"
}

# Show progress indicator
show_progress() {
    local pid=$1
    local test_name=$2
    local spin='-\|/'
    local i=0
    local start_time=$(date +%s)
    
    echo -ne "  Running... "
    
    while kill -0 $pid 2>/dev/null; do
        local current_time=$(date +%s)
        local elapsed=$((current_time - start_time))
        
        # Check if test is taking too long
        if [[ $elapsed -ge $MAX_TEST_DURATION ]]; then
            echo -e "\n${RED}Test timed out after ${MAX_TEST_DURATION} seconds${NC}"
            kill -9 $pid 2>/dev/null
            return 1
        fi
        
        i=$(( (i+1) % 4 ))
        printf "\r  Running... ${spin:$i:1} (%ds)" "$elapsed"
        sleep .3
    done
    printf "\r  Completed in %ds       \n" "$elapsed"
    return 0
}

# Run a specific test
run_test() {
    local test_file="$1"
    local test_name="$(basename "$test_file" .sh)"
    
    echo -e "\n${YELLOW}Running test: ${test_name}${NC}"
    
    # Skip test if it has a .skip file
    if [[ -f "${SCRIPT_DIR}/${test_file}.skip" ]]; then
        echo -e "${YELLOW}SKIPPED${NC}: Test $test_name (see .skip file for reason)"
        return 2
    fi
    
    # Run the test with appropriate environment
    if [[ "$USE_MOCK_ENV" == true ]]; then
        # Run with mock environment
        if [[ "$VERBOSE" == true ]]; then
            # Run in verbose mode with direct output
            TEST_MODE=1 \
            MOCK_HOME="${SCRIPT_DIR}/mocks" \
            PERF_SCRIPTS_DIR="${PERF_DIR}" \
            bash "${SCRIPT_DIR}/${test_file}"
            RESULT=$?
        else
            # Run with output redirection and optional progress indicator
            OUTPUT_FILE="${SCRIPT_DIR}/mocks/test_output.log"
            TEST_MODE=1 \
            MOCK_HOME="${SCRIPT_DIR}/mocks" \
            PERF_SCRIPTS_DIR="${PERF_DIR}" \
            bash "${SCRIPT_DIR}/${test_file}" > "$OUTPUT_FILE" 2>&1 &
            
            TEST_PID=$!
            
            # Show progress indicator if enabled
            if [[ "$SHOW_PROGRESS" == true ]]; then
                show_progress $TEST_PID "$test_name"
                PROGRESS_RESULT=$?
                
                # If test timed out
                if [[ $PROGRESS_RESULT -ne 0 ]]; then
                    echo -e "${RED}Test timed out after ${MAX_TEST_DURATION} seconds. Last output:${NC}"
                    tail -n 20 "$OUTPUT_FILE"
                    echo -e "${YELLOW}See full log in: ${OUTPUT_FILE}${NC}"
                    return 1
                fi
            else
                # Just wait for completion with no progress indicator
                wait $TEST_PID
            fi
            
            # Get test result
            wait $TEST_PID 2>/dev/null
            RESULT=$?
            
            # Show output if test failed
            if [[ $RESULT -ne 0 ]]; then
                echo -e "${RED}Test failed, last 20 lines of output:${NC}"
                tail -n 20 "$OUTPUT_FILE"
                echo -e "${YELLOW}See full log in: ${OUTPUT_FILE}${NC}"
            fi
        fi
    else
        # Run in real environment (with warning)
        echo -e "${RED}Warning: Running in real environment. This may modify your system.${NC}"
        read -p "Are you sure you want to continue? (y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo -e "${RED}Test aborted.${NC}"
            return 3
        fi
        
        bash "${SCRIPT_DIR}/${test_file}"
        RESULT=$?
    fi
    
    # Show result
    if [[ $RESULT -eq 0 ]]; then
        echo -e "${GREEN}✓ ${test_name} passed${NC}"
    else
        echo -e "${RED}✗ ${test_name} failed${NC}"
    fi
    
    return $RESULT
}

# Run all specified tests
run_all_tests() {
    local passed=0
    local failed=0
    local skipped=0
    local failed_tests=()
    
    # Banner
    echo -e "${BOLD}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}║            ${BLUE}CURSOR PERFORMANCE SCRIPTS TEST SUITE${NC}            ${BOLD}║${NC}"
    echo -e "${BOLD}╚════════════════════════════════════════════════════════════╝${NC}"
    echo
    
    # Display mode
    if [[ "$USE_MOCK_ENV" == true ]]; then
        echo -e "${BLUE}Running in mock environment mode${NC}"
    else
        echo -e "${RED}Running in real environment mode${NC}"
    fi
    
    # Create mock environment if needed
    if [[ "$USE_MOCK_ENV" == true ]]; then
        create_mock_env
    fi
    
    # Run each test
    for test in "${TEST_FILES[@]}"; do
        run_test "$test"
        result=$?
        
        case $result in
            0)
                ((passed++))
                ;;
            2)
                ((skipped++))
                ;;
            *)
                ((failed++))
                failed_tests+=("$test")
                ;;
        esac
    done
    
    # Clean up mock environment if needed
    if [[ "$USE_MOCK_ENV" == true ]]; then
        cleanup_mock_env
    fi
    
    # Print summary
    echo -e "\n${YELLOW}Test Summary:${NC}"
    echo -e "${GREEN}Tests passed: ${passed}${NC}"
    echo -e "${YELLOW}Tests skipped: ${skipped}${NC}"
    
    if [[ $failed -gt 0 ]]; then
        echo -e "${RED}Tests failed: ${failed}${NC}"
        echo -e "${RED}Failed tests:${NC}"
        for test in "${failed_tests[@]}"; do
            echo -e "${RED}- ${test}${NC}"
        done
        return 1
    else
        echo -e "${GREEN}All tests passed or skipped!${NC}"
        return 0
    fi
}

# Run coverage reports
run_coverage_reports() {
    if [[ "$RUN_COVERAGE" != true ]]; then
        return 0
    fi
    
    echo -e "\n${YELLOW}Running coverage analysis...${NC}"
    
    if [[ "$DETAILED_COVERAGE" == true ]]; then
        # Run detailed HTML coverage report
        bash "${SCRIPT_DIR}/coverage_tracker.sh"
    else
        # Run simple text coverage report
        bash "${SCRIPT_DIR}/simple_coverage_report.sh"
    fi
}

# Main execution
main() {
    find_test_files
    
    # Verify we have tests to run
    if [[ ${#TEST_FILES[@]} -eq 0 ]]; then
        echo -e "${RED}Error: No test files found${NC}" >&2
        exit 1
    fi
    
    # Set up safe mode if enabled
    if [[ "$NO_EXECUTE" -eq 1 ]]; then
        echo "Running in safe mode - no real system commands will be executed"
        # Create override functions file
        OVERRIDE_FILE="${TESTS_DIR}/temp_override_functions.sh"
        cat > "${OVERRIDE_FILE}" << EOF
#!/bin/bash

# Override function for 'code' to prevent VS Code windows from opening
code() {
    echo "SAFE_MODE: Would have run: code \$@"
    return 0
}

# Override function for 'xdg-open' to prevent files from opening
xdg-open() {
    echo "SAFE_MODE: Would have run: xdg-open \$@"
    return 0
}

# Export these functions
export -f code
export -f xdg-open
EOF
        
        # Export environment variable for test scripts to know we're in safe mode
        export TEST_SAFE_MODE=1
        export TEST_OVERRIDE_FILE="${OVERRIDE_FILE}"
        
        # Source the override file to apply the overrides globally
        source "${OVERRIDE_FILE}"
    else
        # Not in safe mode - warn user
        echo -e "${RED}WARNING: Running without safe mode - real system commands may execute${NC}"
        echo -e "${RED}Press Ctrl+C to abort or Enter to continue${NC}"
        read -r
        export TEST_SAFE_MODE=0
    fi
    
    # Run tests
    run_all_tests
    local test_result=$?
    
    # Run coverage if requested and tests passed
    if [[ $test_result -eq 0 ]]; then
        run_coverage_reports
    fi
    
    return $test_result
}

# Execute main function
main "$@"
exit $? 