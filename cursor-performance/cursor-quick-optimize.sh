#!/bin/bash

# Cursor Quick Optimize
# Combines the best performance optimizations without requiring user interaction

# Terminal colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Clear screen and show header
clear
echo -e "${BOLD}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║              ${BLUE}CURSOR QUICK PERFORMANCE BOOST${NC}               ${BOLD}║${NC}"
echo -e "${BOLD}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check if Cursor is running
if pgrep -x "cursor" > /dev/null; then
    echo -e "${YELLOW}⚠️  Cursor is currently running${NC}"
    CURSOR_RUNNING=true
else
    echo -e "${GREEN}✅ Cursor is not running${NC} (optimal for cleanup operations)"
    CURSOR_RUNNING=false
fi

# Get system stats
MEM_TOTAL=$(free -h | grep "Mem:" | awk '{print $2}')
MEM_USED=$(free -h | grep "Mem:" | awk '{print $3}')
MEM_FREE=$(free -h | grep "Mem:" | awk '{print $4}')
CURSOR_PROCESSES=$(pgrep -f "cursor" | wc -l)
EXTENSION_COUNT=$(ls -la ~/.cursor/extensions/ 2>/dev/null | wc -l)

echo -e "\n${BOLD}System Overview:${NC}"
echo -e "  Memory: ${MEM_USED} used of ${MEM_TOTAL} (${MEM_FREE} free)"
echo -e "  Cursor Processes: ${CURSOR_PROCESSES}"
echo -e "  Installed Extensions: ${EXTENSION_COUNT}"

# Quick status check for cache
if [ -d ~/.config/Cursor/CachedData ]; then
    CACHED_DATA_SIZE=$(du -sh ~/.config/Cursor/CachedData 2>/dev/null | cut -f1)
    echo -e "  Cached Data: ${CACHED_DATA_SIZE}"
    
    # Warning if cache is large
    if [[ "$CACHED_DATA_SIZE" == *"G"* ]]; then
        echo -e "  ${YELLOW}⚠️  Large cache detected! Cleanup will be performed${NC}"
    fi
fi

echo -e "\n${BOLD}Starting Quick Optimization...${NC}"

# Step 1: Create backup of important settings
echo -e "\n${BLUE}📌 Creating backup of current settings...${NC}"
mkdir -p ~/.cursor_backup
cp ~/.config/Cursor/User/settings.json ~/.cursor_backup/settings.json.bak-$(date +%Y%m%d)
echo -e "${GREEN}✅ Settings backed up to ~/.cursor_backup/${NC}"

# Step 2: Clean cache files if Cursor is not running
if [ "$CURSOR_RUNNING" = false ]; then
    echo -e "\n${BLUE}📌 Cleaning cache files...${NC}"
    
    # Clean GPU cache
    if [ -d ~/.config/Cursor/GPUCache ]; then
        rm -rf ~/.config/Cursor/GPUCache/*
        echo -e "${GREEN}✅ GPU cache cleaned${NC}"
    fi
    
    # Clean Code Cache
    if [ -d ~/.config/Cursor/Code\ Cache ]; then
        rm -rf ~/.config/Cursor/Code\ Cache/*
        echo -e "${GREEN}✅ Code cache cleaned${NC}"
    fi
    
    # Clean logs
    if [ -d ~/.config/Cursor/logs ]; then
        find ~/.config/Cursor/logs -name "*.log" -type f -delete
        echo -e "${GREEN}✅ Log files cleaned${NC}"
    fi
    
    # Clean crash reports
    if [ -d ~/.config/Cursor/Crashpad/completed ]; then
        rm -rf ~/.config/Cursor/Crashpad/completed/*
        echo -e "${GREEN}✅ Crash reports cleaned${NC}"
    fi
    
    # Clean CachedData (safe parts only)
    if [ -d ~/.config/Cursor/CachedData ]; then
        # Keep database files but remove other cached data
        find ~/.config/Cursor/CachedData -type f -not -name "*.db" -not -name "*.sqlite" -delete
        echo -e "${GREEN}✅ Cached data cleaned (preserving databases)${NC}"
    fi
else
    echo -e "\n${YELLOW}⚠️ Skipping cache cleanup while Cursor is running${NC}"
    echo -e "   Please close Cursor and run this script again for full optimization"
fi

# Step 3: Manually modify extension states without opening VS Code windows
echo -e "\n${BLUE}📌 Disabling non-essential extensions...${NC}"

# List of commonly non-essential extensions for most projects
NON_ESSENTIAL_EXTENSIONS=(
    "dart-code.dart-code"
    "dart-code.flutter"
    "vscjava.vscode-java-pack"
    "ms-dotnettools.csharp"
    "hashicorp.terraform"
    "adrienaudouard.flutter-utils"
    "coolbear.systemd-unit-file"
    "aeschli.vscode-css-formatter"
    "danielmedium.dscodegpt"
    "ms-azuretools.vscode-docker"
    "ms-kubernetes-tools.vscode-kubernetes-tools"
    "golang.go"
    "rust-lang.rust-analyzer"
    "svelte.svelte-vscode"
    "vue.volar"
    "dbaeumer.vscode-eslint"
    "esbenp.prettier-vscode"
)

# Essential extensions that should never be disabled
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

# Create a function to check if an extension is essential
is_essential() {
    local extension="$1"
    for ess in "${ESSENTIAL_EXTENSIONS[@]}"; do
        if [[ "$extension" == "$ess"* ]]; then
            return 0
        fi
    done
    return 1
}

# Directly create/modify the extension state files instead of using the code command
# This avoids opening VS Code windows
disabled_count=0
EXTENSION_DIR=~/.cursor/extensions

if [ -d "$EXTENSION_DIR" ]; then
    echo -e "${BLUE}Using direct extension state modification (no VS Code windows)${NC}"
    
    # Get list of installed extensions with version numbers
    installed_extensions=$(find "$EXTENSION_DIR" -maxdepth 1 -type d -not -path "$EXTENSION_DIR")
    
    for ext in "${NON_ESSENTIAL_EXTENSIONS[@]}"; do
        # Find matching extension directories (with version numbers)
        matching_exts=$(find "$EXTENSION_DIR" -maxdepth 1 -type d -name "${ext}*")
        
        if [ -n "$matching_exts" ]; then
            while read -r matching_ext; do
                ext_name=$(basename "$matching_ext")
                if ! is_essential "$ext_name"; then
                    # Check if it's already disabled
                    if [ ! -f "$EXTENSION_DIR/$ext_name.disabled" ]; then
                        echo -e "${BLUE}Disabling extension:${NC} $ext_name"
                        # Create a marker file to disable the extension
                        touch "$EXTENSION_DIR/$ext_name.disabled"
                        ((disabled_count++))
                    else
                        echo -e "${YELLOW}Already disabled:${NC} $ext_name"
                    fi
                fi
            done <<< "$matching_exts"
        fi
    done
    
    echo -e "${GREEN}✅ Disabled $disabled_count non-essential extensions${NC}"
    echo -e "${YELLOW}⚠️  You will need to restart Cursor for these changes to take effect${NC}"
else
    echo -e "${RED}Error: Extensions directory not found${NC}"
fi

# Step 4: Check memory allocation in argv.json
echo -e "\n${BLUE}📌 Checking memory allocation...${NC}"
ARGV_FILE=~/.config/Cursor/argv.json

if [ -f "$ARGV_FILE" ]; then
    if grep -q "max-old-space-size" "$ARGV_FILE"; then
        echo -e "${GREEN}✅ Memory allocation already configured in argv.json${NC}"
    else
        # Create backup
        cp "$ARGV_FILE" "$ARGV_FILE.bak"
        
        # Add memory allocation (6GB)
        TMP_FILE=$(mktemp)
        jq '. + {"js-flags": "--max-old-space-size=6144"}' "$ARGV_FILE" > "$TMP_FILE"
        mv "$TMP_FILE" "$ARGV_FILE"
        
        echo -e "${GREEN}✅ Memory allocation added to argv.json (6GB)${NC}"
    fi
else
    echo -e "${YELLOW}⚠️ argv.json not found. Creating it...${NC}"
    
    # Create directory if it doesn't exist
    mkdir -p ~/.config/Cursor
    
    # Create argv.json with memory allocation
    echo '{
  "enable-crash-reporter": true,
  "js-flags": "--max-old-space-size=6144"
}' > "$ARGV_FILE"
    
    echo -e "${GREEN}✅ Created argv.json with memory allocation (6GB)${NC}"
fi

# Step 5: Summary and recommendations
echo -e "\n${BOLD}${GREEN}🎉 Quick Optimization Complete! 🎉${NC}"
echo -e "\n${BOLD}Actions Taken:${NC}"
echo -e "  ✅ Settings backed up"
if [ "$CURSOR_RUNNING" = false ]; then
    echo -e "  ✅ Cache files cleaned"
else
    echo -e "  ⚠️ Cache cleaning skipped (Cursor running)"
fi
echo -e "  ✅ Non-essential extensions disabled: $disabled_count"
echo -e "  ✅ Memory allocation checked/configured"

echo -e "\n${BOLD}Next Steps:${NC}"
if [ "$CURSOR_RUNNING" = true ]; then
    echo -e "  1. ${YELLOW}Restart Cursor${NC} to apply all optimizations"
else
    echo -e "  1. Start Cursor with optimized performance"
fi
echo -e "  2. Use only 1-2 Composer Agents at a time"
echo -e "  3. Close unused editor tabs and workspaces"
echo -e "  4. Run the performance monitor to check improvement:"
echo -e "     ${BOLD}./.vscode/performance/cursor-monitor.sh${NC}"

echo -e "\n${BOLD}For More Options:${NC}"
echo -e "  Run the full performance dashboard:"
echo -e "  ${BOLD}./.vscode/performance/cursor-performance-dashboard.sh${NC}"
echo "" 