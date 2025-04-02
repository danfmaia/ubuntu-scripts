#!/bin/bash

# Safe Cursor Performance Optimization Script
# This script focuses ONLY on safe optimization techniques that won't affect agent history

echo "🛡️ Safe Cursor Performance Optimization Script 🛡️"
echo "=================================================="
echo ""
echo "⚠️  This script will not delete any conversation or agent history."
echo "⚠️  Press Ctrl+C to abort, or press Enter to continue..."
read

# Check if Cursor is running
echo "📌 Checking for running Cursor processes..."
if pgrep -x "cursor" > /dev/null; then
    echo "⚠️  Cursor is still running."
    echo "⚠️  Some optimizations are still safe to apply, but a full restart"
    echo "    will be needed for all benefits."
else
    echo "✅ No Cursor processes found. All optimizations can be applied."
fi

# Create backup of important settings
echo "📌 Creating backup of current settings..."
mkdir -p ~/.cursor_backup
cp ~/.config/Cursor/User/settings.json ~/.cursor_backup/settings.json.bak-$(date +%Y%m%d)
echo "✅ Settings backed up to ~/.cursor_backup/"

# Generate performance settings
echo "📌 Generating performance-optimized settings..."
cat > ./cursor-performance-settings.json << EOL
{
  "editor.cursorSmoothCaretAnimation": false,
  "editor.smoothScrolling": false,
  "editor.renderWhitespace": "none",
  "editor.minimap.enabled": false,
  "editor.renderControlCharacters": false,
  "editor.renderLineHighlight": "none",
  "workbench.enableExperiments": false,
  "workbench.colorDecorators": false,
  "editor.bracketPairColorization.enabled": false,
  "editor.guides.indentation": false,
  "editor.occurrencesHighlight": false,
  "typescript.tsserver.experimental.enableProjectDiagnostics": false,
  "workbench.editor.enablePreview": false,
  "window.autoDetectColorScheme": false,
  "diffEditor.renderSideBySide": false,
  "diffEditor.ignoreTrimWhitespace": true,
  "editor.suggest.showStatusBar": false,
  "telemetry.telemetryLevel": "off"
}
EOL
echo "✅ Performance settings file created: cursor-performance-settings.json"

# Clean only safe cache files (no database or history files)
if ! pgrep -x "cursor" > /dev/null; then
    echo "📌 Safely cleaning some browser cache files..."
    # Only clean GPU cache and Code Cache, which are safe to remove
    rm -rf ~/.config/Cursor/GPUCache/*
    echo "✅ GPU cache cleaned."
else
    echo "ℹ️ Skipping cache cleanup while Cursor is running."
fi

# Check extensions
echo "📌 Checking extensions..."
EXTENSION_COUNT=$(ls -la ~/.cursor/extensions/ | wc -l)
echo "ℹ️ You have approximately $EXTENSION_COUNT extensions installed."
echo "ℹ️ Consider temporarily disabling some extensions:"
echo "   1. Open Cursor settings (File > Preferences > Settings)"
echo "   2. Search for 'extensions'"
echo "   3. Find 'Disable All Installed Extensions' to quickly toggle them off"
echo "   4. Or individually disable non-critical extensions"

echo ""
echo "🎉 Safe optimization steps complete! 🎉"
echo ""
echo "To apply these optimizations:"
echo ""
echo "1. If Cursor is running:"
echo "   - Open settings (File > Preferences > Settings)"
echo "   - Click the {} icon in the top right to edit settings as JSON"
echo "   - Copy settings from cursor-performance-settings.json"
echo "   - Paste at the appropriate location in your settings.json"
echo "   - Save the file"
echo ""
echo "2. For maximum performance improvement:"
echo "   - Close Cursor completely"
echo "   - Run this script again to clean cache files"
echo "   - Restart Cursor with fewer agents (1-2 max)"
echo ""
echo "3. Additional performance tips:"
echo "   - Avoid having multiple composer agents active simultaneously"
echo "   - Close unused workspace tabs regularly"
echo "   - Use 'Cursor Doctor' from the command palette if issues persist"
echo "   - Consider allocating more RAM to Cursor if your system has ample memory:"
echo ""
echo "     Add this line to ~/.config/Cursor/argv.json if it exists:"
echo "     [\"--js-flags=--max-old-space-size=4096\"]" 