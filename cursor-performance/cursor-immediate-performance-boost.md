# Cursor Immediate Performance Boost Guide

This guide will help you improve Cursor performance **without closing Cursor** and without risking any loss of agent history or conversations.

## Immediate Performance Improvements

### 1. Disable Heavy Editor Features

Open Cursor settings (File > Preferences > Settings) and set the following:

```json
{
  "editor.cursorSmoothCaretAnimation": false,
  "editor.smoothScrolling": false,
  "editor.minimap.enabled": false
}
```

These three settings alone can dramatically improve performance, especially cursor responsiveness.

### 2. Reduce Active Agents

Multiple active Composer Agents can significantly slow down Cursor:

1. Keep only 1-2 agents active at once
2. Use "Restart Agent" option before switching contexts (instead of creating new agents)
3. Use the Cursor command palette (Ctrl+Shift+P) and type "Restart Agent" to refresh an agent

### 3. Close Unused Tabs and Workspaces

Each open file and workspace consumes memory:

1. Close any unnecessary editor tabs
2. Close unused workspace folders
3. Use "Close All Editors" from the File menu when switching contexts

### 4. Disable Unused Extensions

Extensions can consume significant resources:

1. Open settings and search for "Extensions: Auto Update"
2. Disable auto-updates to prevent background processes
3. Consider temporarily disabling non-critical extensions

### 5. Use "Cursor Doctor"

Cursor has a built-in diagnostic tool:

1. Open the command palette (Ctrl+Shift+P)
2. Type "Cursor Doctor" and select it
3. Follow any performance recommendations

## Additional Tips

- **Restart Cursor periodically** (every few days)
- **Run our `cursor-cleanup-safe.sh` script** after closing Cursor for deeper optimization
- **Set workspace trust to Restricted** to prevent unknown code from running
- **Avoid having a large number of files open in search results**
- **Disable complex syntax highlighting** for very large files

## Apply Performance Settings Without Restart

You can apply most settings without restarting by:

1. Open settings (Ctrl+,)
2. Click the "{}" icon in the top-right corner to view in JSON mode
3. Add or modify the settings as needed
4. Save the file (Ctrl+S)

The changes will be applied immediately for most settings without losing any context or history.
