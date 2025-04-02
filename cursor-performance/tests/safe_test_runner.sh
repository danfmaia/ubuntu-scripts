#!/bin/bash

# Safe Test Runner for Cursor Performance Scripts
# This script overrides potentially harmful commands with safe versions before running tests

# Terminal colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Display header
echo -e "${BOLD}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║           ${BLUE}SAFE TEST RUNNER FOR CURSOR SCRIPTS${NC}             ${BOLD}║${NC}"
echo -e "${BOLD}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Get directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Override harmful commands
echo -e "${YELLOW}Setting up safe environment...${NC}"

# Create temporary script with overrides
TEMP_OVERRIDE="${SCRIPT_DIR}/temp_safe_overrides.sh"
cat > "${TEMP_OVERRIDE}" << EOF
#!/bin/bash

# Override dangerous commands with safe versions

# Override 'code' to prevent VS Code windows
code() {
    echo "SAFE_TEST: Would have opened in VS Code: \$@"
    return 0
}

# Override 'xdg-open' to prevent files from opening
xdg-open() {
    echo "SAFE_TEST: Would have opened with xdg-open: \$@"
    return 0
}

# Export the functions
export -f code
export -f xdg-open

# Signal that we're in safe mode
export CURSOR_TEST_SAFE_MODE=1
EOF

# Make the override script executable
chmod +x "${TEMP_OVERRIDE}"

# Source the override script to apply the overrides
source "${TEMP_OVERRIDE}"

echo -e "${GREEN}✓ Safe environment ready - VS Code windows and file opens are blocked${NC}"
echo ""

# Run the requested test with safety overrides in place
if [ $# -eq 0 ]; then
    echo -e "${RED}ERROR: Please specify a test to run${NC}"
    echo "Usage: $0 test_script.sh [args]"
    exit 1
fi

TEST_SCRIPT="$1"
shift

echo -e "${YELLOW}Running test: ${TEST_SCRIPT}${NC}"

# Set up mock environment
MOCK_DIR="${SCRIPT_DIR}/mocks"
rm -rf "${MOCK_DIR}" # Clean up any existing mock environment
mkdir -p "${MOCK_DIR}/config/Cursor/CachedData"
mkdir -p "${MOCK_DIR}/config/Cursor/Code Cache"
mkdir -p "${MOCK_DIR}/config/Cursor/GPUCache"
mkdir -p "${MOCK_DIR}/config/Cursor/User/workspaceStorage"
mkdir -p "${MOCK_DIR}/config/Cursor/logs"
mkdir -p "${MOCK_DIR}/config/Cursor/Crashpad/completed"
mkdir -p "${MOCK_DIR}/.cursor_backup"
mkdir -p "${MOCK_DIR}/.cursor/extensions"
mkdir -p "${MOCK_DIR}/processes"

# Create mock process file
echo "3" > "${MOCK_DIR}/processes/cursor"

# Create mock settings files
echo '{
  "editor.cursorSmoothCaretAnimation": "on",
  "editor.smoothScrolling": true
}' > "${MOCK_DIR}/config/Cursor/User/settings.json"

# Create mock cached data
dd if=/dev/zero of="${MOCK_DIR}/config/Cursor/CachedData/test1.bin" bs=1M count=5 2>/dev/null
dd if=/dev/zero of="${MOCK_DIR}/config/Cursor/Code Cache/test2.bin" bs=1M count=5 2>/dev/null
dd if=/dev/zero of="${MOCK_DIR}/config/Cursor/GPUCache/test3.bin" bs=1M count=5 2>/dev/null
dd if=/dev/zero of="${MOCK_DIR}/config/Cursor/logs/cursor.log" bs=1K count=10 2>/dev/null
dd if=/dev/zero of="${MOCK_DIR}/config/Cursor/Crashpad/completed/crash1.dmp" bs=1K count=10 2>/dev/null

# Create mock extensions (for extension count testing)
for ext in {1..3}; do
    mkdir -p "${MOCK_DIR}/.cursor/extensions/mockext_${ext}"
    echo "Mock extension" > "${MOCK_DIR}/.cursor/extensions/mockext_${ext}/package.json"
done

# Create mock scripts in the mock directory
MOCK_SCRIPTS_DIR="${MOCK_DIR}/mock_scripts"
mkdir -p "${MOCK_SCRIPTS_DIR}"

# Copy the dashboard script to our mock directory
cp "$(dirname "${SCRIPT_DIR}")/cursor-performance-dashboard.sh" "${MOCK_SCRIPTS_DIR}/"

# Create a mock monitor script
cat > "${MOCK_SCRIPTS_DIR}/cursor-monitor.sh" << EOF
#!/bin/bash
echo "MOCK: Performance Monitor Script"
echo "This is a mock script that would normally monitor Cursor usage"
echo "Script execution is safely prevented in test mode"
exit 0
EOF

# Create a mock cleanup script
cat > "${MOCK_SCRIPTS_DIR}/cursor-cleanup-safe.sh" << EOF
#!/bin/bash
echo "MOCK: Cleanup Script"
echo "This is a mock script that would normally clean up Cursor caches"
echo "Script execution is safely prevented in test mode"
exit 0
EOF

# Create a mock extension manager script
cat > "${MOCK_SCRIPTS_DIR}/cursor-disable-extensions.sh" << EOF
#!/bin/bash
echo "MOCK: Extension Manager Script"
echo "This is a mock script that would normally manage Cursor extensions"
echo "Script execution is safely prevented in test mode"
exit 0
EOF

# Make the mock scripts executable
chmod +x "${MOCK_SCRIPTS_DIR}"/*.sh

# Set a special environment variable to help the test framework
export MOCK_SCRIPTS_DIR="${MOCK_SCRIPTS_DIR}"

# Set required environment variables
export TEST_MODE=1
export MOCK_HOME="${MOCK_DIR}"
export PERF_SCRIPTS_DIR="${MOCK_SCRIPTS_DIR}"

echo -e "${GREEN}✓ Test environment prepared${NC}"

# Run the test with required environment variables
bash "${SCRIPT_DIR}/${TEST_SCRIPT}" "$@"
EXIT_CODE=$?

# Clean up
rm -f "${TEMP_OVERRIDE}"
rm -rf "${MOCK_DIR}"

if [ $EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}✓ Test completed successfully${NC}"
else
    echo -e "${RED}✗ Test failed with exit code ${EXIT_CODE}${NC}"
fi

exit $EXIT_CODE 