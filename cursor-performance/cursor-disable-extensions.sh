#!/bin/bash

# Cursor Extension Disabler
# Quickly disable non-critical extensions for immediate performance boost

# Terminal colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Check for direct command line extensions to disable
if [ $# -gt 0 ]; then
    # Non-interactive mode - directly disable specified extensions
    echo -e "${BLUE}Running in non-interactive mode to disable specified extensions${NC}"
    
    # Essential extensions for InvoiceForge
    ESSENTIAL_EXTENSIONS=(
        "ms-python.python"
        "ms-python.vscode-pylance"
        "ms-python.flake8"
        "ms-python.mypy-type-checker"
        "ms-python.debugpy"
        "ms-python.python-indent"
        "eamodio.gitlens"
        "vscode-icons-team.vscode-icons"
        "yzhang.markdown-all-in-one"
    )
    
    # Utility function to check if an extension is in the essential list
    is_essential() {
        local extension="$1"
        for ess in "${ESSENTIAL_EXTENSIONS[@]}"; do
            if [[ "$extension" == "$ess"* ]]; then
                return 0
            fi
        done
        return 1
    }
    
    # Process each extension argument using direct file modification
    EXTENSION_DIR=~/.cursor/extensions
    disabled_count=0
    skipped_count=0
    
    if [ ! -d "$EXTENSION_DIR" ]; then
        echo -e "${RED}Error: Extensions directory not found at $EXTENSION_DIR${NC}"
        exit 1
    fi
    
    for ext in "$@"; do
        if is_essential "$ext"; then
            echo -e "${YELLOW}Skipping essential extension:${NC} $ext"
            ((skipped_count++))
        else
            # Find matching extension directory (with version number)
            matching_ext=$(find "$EXTENSION_DIR" -maxdepth 1 -type d -name "${ext}*" | head -n 1)
            
            if [ -n "$matching_ext" ]; then
                ext_name=$(basename "$matching_ext")
                echo -e "${BLUE}Disabling extension:${NC} $ext_name"
                # Create a marker file to disable the extension
                touch "$EXTENSION_DIR/$ext_name.disabled"
                ((disabled_count++))
            else
                echo -e "${YELLOW}Extension not found:${NC} $ext"
            fi
        fi
    done
    
    echo -e "\n${GREEN}✅ Action complete:${NC}"
    echo -e "  ${GREEN}Disabled:${NC} $disabled_count extensions"
    echo -e "  ${YELLOW}Skipped:${NC} $skipped_count essential extensions"
    echo -e "\n${YELLOW}⚠️  You may need to restart Cursor for changes to take effect.${NC}"
    exit 0
fi

# Interactive mode below
# Clear screen and show header
clear
echo -e "${BOLD}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║                ${BLUE}CURSOR EXTENSION MANAGER${NC}                     ${BOLD}║${NC}"
echo -e "${BOLD}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Essential extensions for InvoiceForge
ESSENTIAL_EXTENSIONS=(
    "ms-python.python"
    "ms-python.vscode-pylance"
    "ms-python.flake8"
    "ms-python.mypy-type-checker"
    "ms-python.debugpy"
    "ms-python.python-indent"
    "eamodio.gitlens"
    "vscode-icons-team.vscode-icons"
    "yzhang.markdown-all-in-one"
)

# Utility function to check if an extension is in the essential list
is_essential() {
    local extension="$1"
    for ess in "${ESSENTIAL_EXTENSIONS[@]}"; do
        if [[ "$extension" == "$ess"* ]]; then
            return 0
        fi
    done
    return 1
}

# Utility function to display a spinner
spinner() {
    local delay=0.1
    local spinstr='|/-\'
    for i in {1..10}; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# Extension directory
EXTENSION_DIR=~/.cursor/extensions

# Get all installed extensions
echo -e "${BLUE}Fetching installed extensions...${NC}"
if [ ! -d "$EXTENSION_DIR" ]; then
    echo -e "${RED}Error: Extensions directory not found at $EXTENSION_DIR${NC}"
    exit 1
fi

# Get list of extension directories (with version numbers)
EXTENSIONS=$(find "$EXTENSION_DIR" -maxdepth 1 -type d -not -path "$EXTENSION_DIR" | sort)
EXTENSION_COUNT=$(echo "$EXTENSIONS" | wc -l)

# Count essential extensions
ESSENTIAL_COUNT=0
for ext in $EXTENSIONS; do
    ext_name=$(basename "$ext")
    if is_essential "$ext_name"; then
        ((ESSENTIAL_COUNT++))
    fi
done

NON_ESSENTIAL_COUNT=$((EXTENSION_COUNT - ESSENTIAL_COUNT))

echo -e "\n${BOLD}Extension Summary:${NC}"
echo -e "  Total Extensions: ${EXTENSION_COUNT}"
echo -e "  Essential Extensions: ${ESSENTIAL_COUNT}"
echo -e "  Non-Essential Extensions: ${NON_ESSENTIAL_COUNT}"

# Display menu options
echo -e "\n${BOLD}Available Actions:${NC}"
echo -e "${GREEN}1.${NC} Disable All Non-Essential Extensions"
echo -e "${GREEN}2.${NC} Enable Only Essential Extensions"
echo -e "${GREEN}3.${NC} List All Extensions (Essential/Non-Essential)"
echo -e "${GREEN}4.${NC} List Essential Extensions"
echo -e "${RED}5.${NC} Exit"

# Get user choice
echo -e "\n${BOLD}Choose an option (1-5):${NC}"
read -r choice

case $choice in
    1)
        echo -e "\n${BLUE}Disabling non-essential extensions...${NC}"
        count=0
        for ext in $EXTENSIONS; do
            ext_name=$(basename "$ext")
            if ! is_essential "$ext_name"; then
                echo -e "${YELLOW}Disabling:${NC} $ext_name"
                touch "$EXTENSION_DIR/$ext_name.disabled"
                spinner
                ((count++))
            fi
        done
        echo -e "\n${GREEN}✅ Disabled $count non-essential extensions.${NC}"
        echo -e "${YELLOW}⚠️  You may need to restart Cursor for changes to take effect.${NC}"
        ;;
    2)
        echo -e "\n${BLUE}Disabling ALL extensions first...${NC}"
        # Create .disabled files for all extensions
        for ext in $EXTENSIONS; do
            ext_name=$(basename "$ext")
            touch "$EXTENSION_DIR/$ext_name.disabled"
        done
        spinner
        
        echo -e "\n${BLUE}Re-enabling essential extensions...${NC}"
        for ext in $EXTENSIONS; do
            ext_name=$(basename "$ext")
            if is_essential "$ext_name"; then
                if [ -f "$EXTENSION_DIR/$ext_name.disabled" ]; then
                    rm -f "$EXTENSION_DIR/$ext_name.disabled"
                    echo -e "${GREEN}Enabled:${NC} $ext_name"
                    spinner
                fi
            fi
        done
        echo -e "\n${GREEN}✅ Enabled only essential extensions.${NC}"
        echo -e "${YELLOW}⚠️  You may need to restart Cursor for changes to take effect.${NC}"
        ;;
    3)
        echo -e "\n${BLUE}Listing all extensions:${NC}"
        for ext in $EXTENSIONS; do
            ext_name=$(basename "$ext")
            if is_essential "$ext_name"; then
                echo -e "${GREEN}[ESSENTIAL]${NC} $ext_name"
            else
                echo -e "${YELLOW}[NON-ESSENTIAL]${NC} $ext_name"
            fi
        done
        # Also show disabled extensions
        echo -e "\n${BLUE}Currently disabled extensions:${NC}"
        disabled_exts=$(find "$EXTENSION_DIR" -name "*.disabled" | sed 's|.*/\(.*\)\.disabled|\1|')
        if [ -z "$disabled_exts" ]; then
            echo -e "  ${YELLOW}None${NC}"
        else
            echo "$disabled_exts" | while read -r dext; do
                echo -e "  ${RED}[DISABLED]${NC} $dext"
            done
        fi
        ;;
    4)
        echo -e "\n${BLUE}Essential extensions for InvoiceForge:${NC}"
        for ext in "${ESSENTIAL_EXTENSIONS[@]}"; do
            echo -e "  ${GREEN}$ext${NC}"
        done
        ;;
    5)
        echo -e "\n${BLUE}Exiting.${NC}"
        exit 0
        ;;
    *)
        echo -e "\n${RED}Invalid option. Please run again and select 1-5.${NC}"
        exit 1
        ;;
esac

echo -e "\n${BOLD}Next Steps:${NC}"
echo -e "1. Restart Cursor to apply extension changes"
echo -e "2. Run the performance monitor to check improvement:"
echo -e "   ${BOLD}./.vscode/performance/cursor-monitor.sh${NC}"
echo -e "3. Run the performance dashboard for more optimization options:"
echo -e "   ${BOLD}./.vscode/performance/cursor-performance-dashboard.sh${NC}"
echo "" 