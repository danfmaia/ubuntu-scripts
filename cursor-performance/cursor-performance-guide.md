# Cursor Performance Optimization Guide

This guide provides comprehensive strategies for optimizing Cursor performance, especially when working with multiple Composer Agents on the InvoiceForge project.

## Quick Fixes for Immediate Performance Boost

If you're experiencing slowness right now:

1. **Disable smooth animations and scrolling**:

   - Open settings (Ctrl+,)
   - Set `editor.cursorSmoothCaretAnimation` to `off`
   - Set `editor.smoothScrolling` to `false`
   - Set `editor.minimap.enabled` to `false`

2. **Reduce active Composer Agents**:

   - Keep only 1-2 agents active at once
   - Use "Restart Agent" instead of creating new agents

3. **Close unused tabs and workspaces**:

   - Use "Close All Editors" from the File menu
   - Close unused workspace folders

4. **Temporarily disable extensions**:
   - Open Command Palette (Ctrl+Shift+P)
   - Type "Extensions: Disable All Installed Extensions"
   - Restart Cursor

## Performance Optimization Tools

This project includes several tools to help optimize Cursor performance:

1. **Cursor Cleanup Script** (safe version):

   ```bash
   ./.vscode/cursor-cleanup-safe.sh
   ```

   This script safely cleans up Cursor cache files without affecting agent history.

2. **Cursor Performance Monitor**:

   ```bash
   ./.vscode/cursor-monitor.sh
   ```

   This script monitors Cursor's resource usage and provides insights.

3. **Performance-Optimized Settings**:

   - Global settings in `~/.config/Cursor/User/settings.json`
   - Project-specific settings in `.vscode/settings.json`

4. **Extension Management Guide**:
   - See `.vscode/cursor-extension-management.md` for detailed guidance

## Comprehensive Optimization Strategy

### 1. Memory Allocation

Cursor's memory allocation has been increased to 6GB in `~/.config/Cursor/argv.json`:

```json
{
  "enable-crash-reporter": true,
  "enable-proposed-api": ["cursor.webviews"],
  "js-flags": "--max-old-space-size=6144"
}
```

If you have more RAM available, you can increase this further (e.g., to 8192 for 8GB).

### 2. Visual Features Optimization

The following visual features have been disabled to improve performance:

- Smooth cursor animation
- Smooth scrolling
- Minimap
- Whitespace rendering
- Control character rendering
- Line highlighting
- Bracket pair colorization
- Indentation guides
- Occurrences highlighting

### 3. File Watcher Optimization

File watchers have been optimized to exclude:

- Git objects and cache
- Node modules
- Python cache directories
- Build and distribution directories
- Test cache directories

### 4. Extension Management

With 82 extensions installed, extension management is critical:

1. **Create extension profiles** for different tasks
2. **Disable unused extensions** when not needed
3. **Monitor extension resource usage** with the Process Explorer
4. **Regularly audit extensions** to remove unnecessary ones

### 5. Workspace Management

For optimal performance with multiple agents:

1. **Limit open files** to those actively being worked on
2. **Close unused workspaces** to reduce memory usage
3. **Use workspace trust restrictions** to prevent unknown code execution
4. **Regularly restart Cursor** (every few days)

### 6. Agent Usage Best Practices

When working with Composer Agents:

1. **Limit to 1-2 active agents** at a time
2. **Restart agents** instead of creating new ones
3. **Clear agent context** when switching topics
4. **Use "Cursor Doctor"** from the command palette to diagnose issues

## Monitoring and Maintenance

### Regular Maintenance Tasks

1. **Weekly cache cleanup**:

   ```bash
   ./.vscode/cursor-cleanup-safe.sh
   ```

2. **Extension audit** (monthly):

   - Review all installed extensions
   - Remove unused extensions
   - Disable situational extensions when not in use

3. **Performance monitoring**:
   ```bash
   ./.vscode/cursor-monitor.sh
   ```
   Run this script when experiencing performance issues to identify bottlenecks.

### Signs That Cursor Needs Attention

- CPU usage consistently above 50%
- Slow response when typing
- Delayed agent responses
- High memory usage (>4GB)
- Frequent freezing or lag

## Troubleshooting Common Issues

### High CPU Usage

If Cursor is using high CPU:

1. Check which process is consuming resources with `./.vscode/cursor-monitor.sh`
2. Disable extensions with background processes
3. Close unused editors and workspaces
4. Restart Cursor if the issue persists

### Slow Agent Responses

If agents are responding slowly:

1. Reduce the number of active agents
2. Restart the current agent
3. Check for large context windows or complex queries
4. Verify network connectivity to API endpoints

### Editor Lag

If the editor is lagging:

1. Disable smooth scrolling and animations
2. Close large files not being actively edited
3. Disable syntax highlighting for very large files
4. Check extension CPU usage in Process Explorer

## Conclusion

By following these optimization strategies, you can significantly improve Cursor performance while working on the InvoiceForge project, even with multiple Composer Agents.

Remember that the most effective optimizations are:

1. Limiting active agents
2. Managing extensions
3. Disabling smooth animations
4. Regular cache cleanup
5. Increasing memory allocation

For any persistent performance issues, run the monitoring script and consider a full restart of Cursor.
