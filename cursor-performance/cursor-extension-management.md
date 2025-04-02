# Cursor Extension Management for Performance

You currently have approximately 82 extensions installed in Cursor, which can significantly impact performance. This guide will help you manage extensions to improve Cursor's responsiveness, especially when working with multiple Composer Agents.

## Extension Management Strategy

### Critical Extensions (Always Keep Enabled)

These extensions are essential for the InvoiceForge project:

- Python
- Pylance
- Python Indent
- Flake8
- Mypy
- Git
- Git History
- GitLens
- Markdown All in One

### Situational Extensions (Enable Only When Needed)

These extensions should be enabled only when actively using their features:

- Docker
- Remote - Containers
- Database tools
- Jupyter Notebooks
- Testing extensions
- Documentation generators

### Performance-Heavy Extensions (Consider Disabling)

These types of extensions often consume significant resources:

- Real-time linters and validators
- Extensions with file watchers
- Extensions with background processes
- Extensions that perform indexing
- Extensions with web views

## How to Manage Extensions

### Temporarily Disable All Extensions

When experiencing severe performance issues:

1. Open Command Palette (Ctrl+Shift+P)
2. Type "Extensions: Disable All Installed Extensions"
3. Restart Cursor

### Create Extension Profiles

For different development tasks:

1. Open Extensions view (Ctrl+Shift+X)
2. Click on the "..." menu
3. Select "Configure Extension Profiles"
4. Create profiles for different tasks:
   - Core Development (minimal set)
   - Full Development (all tools)
   - Documentation (markdown tools)
   - Testing (test runners and tools)

### Check Extension CPU/Memory Usage

If Cursor is slow, check which extensions are consuming resources:

1. Open Command Palette (Ctrl+Shift+P)
2. Type "Developer: Open Process Explorer"
3. Look for extensions with high CPU or memory usage
4. Disable problematic extensions

## Recommended Extension Workflow

1. Start with minimal extensions enabled
2. Enable additional extensions only when needed
3. Disable extensions after completing specific tasks
4. Regularly review and clean up unused extensions
5. Restart Cursor after enabling/disabling extensions

## Extension Audit Process

Periodically review your extensions:

1. List all extensions: `code --list-extensions`
2. For each extension, ask:
   - When was the last time I used this?
   - Is this essential for my workflow?
   - Is there a lighter alternative?
   - Can I use this feature through other means?
3. Uninstall unused extensions: `code --uninstall-extension EXTENSION_ID`

By following these guidelines, you can significantly improve Cursor performance while maintaining the functionality you need for development.
