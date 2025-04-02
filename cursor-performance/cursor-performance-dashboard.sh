#!/bin/bash

# Cursor Performance Dashboard
# A unified interface for all Cursor performance optimization tools

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
echo -e "${BOLD}║                ${BLUE}CURSOR PERFORMANCE DASHBOARD${NC}                 ${BOLD}║${NC}"
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
        echo -e "  ${YELLOW}⚠️  Large cache detected! Cleanup recommended${NC}"
    fi
fi

# Display menu options
echo -e "\n${BOLD}Available Tools:${NC}"
echo -e "${GREEN}1.${NC} Run Performance Monitor (view resource usage)"
echo -e "${GREEN}2.${NC} Run Safe Cleanup Script (clear caches, preserve history)"
echo -e "${GREEN}3.${NC} Manage Extensions (disable/enable)"
echo -e "${GREEN}4.${NC} View Performance Guide"
echo -e "${GREEN}5.${NC} View Extension Management Guide"
echo -e "${GREEN}6.${NC} Open Performance Settings in Editor"
echo -e "${RED}7.${NC} Exit"

if [ "$CURSOR_RUNNING" = true ]; then
    echo -e "\n${YELLOW}Note: Some cleanup operations will be limited while Cursor is running.${NC}"
fi

# Get user choice
echo -e "\n${BOLD}Choose an option (1-7):${NC}"
read -r choice

case $choice in
    1)
        echo -e "\n${BLUE}Running Performance Monitor...${NC}\n"
        bash ./.vscode/performance/cursor-monitor.sh
        ;;
    2)
        echo -e "\n${BLUE}Running Safe Cleanup Script...${NC}\n"
        bash ./.vscode/performance/cursor-cleanup-safe.sh
        ;;
    3)
        echo -e "\n${BLUE}Running Extension Manager...${NC}\n"
        bash ./.vscode/performance/cursor-disable-extensions.sh
        ;;
    4)
        if command -v xdg-open &> /dev/null; then
            echo -e "\n${YELLOW}⚠️  This will open the performance guide. Continue? (y/n)${NC}"
            read -r confirm
            if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
                xdg-open ./.vscode/performance/cursor-performance-guide.md
                echo -e "${GREEN}✅ Performance guide opened${NC}"
            else
                echo -e "${YELLOW}Operation cancelled by user${NC}"
            fi
        else
            echo -e "\n${RED}Cannot open file automatically. Please open:${NC}"
            echo "./.vscode/performance/cursor-performance-guide.md"
        fi
        ;;
    5)
        if command -v xdg-open &> /dev/null; then
            echo -e "\n${YELLOW}⚠️  This will open the extension management guide. Continue? (y/n)${NC}"
            read -r confirm
            if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
                xdg-open ./.vscode/performance/cursor-extension-management.md
                echo -e "${GREEN}✅ Extension management guide opened${NC}"
            else
                echo -e "${YELLOW}Operation cancelled by user${NC}"
            fi
        else
            echo -e "\n${RED}Cannot open file automatically. Please open:${NC}"
            echo "./.vscode/performance/cursor-extension-management.md"
        fi
        ;;
    6)
        if command -v code &> /dev/null; then
            echo -e "\n${YELLOW}⚠️  This will open settings files in VS Code. Continue? (y/n)${NC}"
            read -r confirm
            if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
                code ~/.config/Cursor/User/settings.json
                code ./.vscode/settings.json
                echo -e "${GREEN}✅ Settings files opened in VS Code${NC}"
            else
                echo -e "${YELLOW}Operation cancelled by user${NC}"
            fi
        else
            echo -e "\n${RED}Cannot open files automatically. Please open:${NC}"
            echo "~/.config/Cursor/User/settings.json"
            echo "./.vscode/settings.json"
        fi
        ;;
    7)
        echo -e "\n${BLUE}Exiting dashboard.${NC}"
        exit 0
        ;;
    *)
        echo -e "\n${RED}Invalid option. Please run again and select 1-7.${NC}"
        exit 1
        ;;
esac

echo -e "\n${GREEN}Done!${NC} Run this dashboard anytime with:"
echo -e "${BOLD}./.vscode/performance/cursor-performance-dashboard.sh${NC}"
echo "" 