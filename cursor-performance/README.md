# Cursor Performance Optimization Toolkit

This toolkit provides a comprehensive set of tools to optimize Cursor's performance, especially when working with multiple Composer Agents on the InvoiceForge project.

## Quick Start

Run the dashboard for an interactive menu of all performance tools:

```bash
./.vscode/performance/cursor-performance-dashboard.sh
```

## Available Tools

| Tool                      | Description                            | Usage                                                       |
| ------------------------- | -------------------------------------- | ----------------------------------------------------------- |
| **Performance Dashboard** | Interactive menu for all tools         | `./.vscode/performance/cursor-performance-dashboard.sh`     |
| **Performance Monitor**   | View real-time resource usage          | `./.vscode/performance/cursor-monitor.sh`                   |
| **Safe Cleanup Script**   | Clean caches without affecting history | `./.vscode/performance/cursor-cleanup-safe.sh`              |
| **Extension Manager**     | Quickly enable/disable extensions      | `./.vscode/performance/cursor-disable-extensions.sh`        |
| **Performance Guide**     | Comprehensive optimization guide       | Open `./.vscode/performance/cursor-performance-guide.md`    |
| **Extension Management**  | Guide for managing extensions          | Open `./.vscode/performance/cursor-extension-management.md` |

## Performance Issues & Solutions

### Current Issues Detected

Based on monitoring, the following performance issues were detected:

- **High CPU Usage**: One Cursor renderer process using 46.1% CPU
- **Large Cache Sizes**: Cached Data at 1.4GB
- **Many Extensions**: 82 extensions installed
- **Multiple Processes**: 33 Cursor processes active

### Key Optimizations Applied

1. **Performance-Optimized Settings**:

   - Disabled animations, minimap, and visual features
   - Optimized file watchers and search indexing
   - Reduced Python analysis scope

2. **Memory Allocation**:

   - Increased to 6GB in `~/.config/Cursor/argv.json`

3. **Extension Management**:
   - Identified critical vs. situational extensions
   - Created tools for quickly disabling non-essential extensions
   - Created guide for managing extensions

## Recommended Workflow

For optimal Cursor performance:

1. **Daily Use**:

   - Keep only 1-2 Composer Agents active
   - Close unused editor tabs and workspaces
   - Use "Restart Agent" instead of creating new ones
   - Disable unnecessary extensions when not in use

2. **Weekly Maintenance**:

   - Run the cleanup script after closing Cursor
   - Monitor performance with the monitoring script

3. **Monthly Review**:
   - Audit extensions and remove unused ones
   - Review and update performance settings

## Support

If you encounter any issues with these tools:

1. Check the comprehensive guide in `./.vscode/performance/cursor-performance-guide.md`
2. Ensure all scripts have executable permissions (`chmod +x ./.vscode/performance/*.sh`)
3. Try running the scripts with bash explicitly: `bash ./.vscode/performance/cursor-performance-dashboard.sh`
