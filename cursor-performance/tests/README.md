# Cursor Performance Scripts Test Suite

This directory contains tests for the Cursor Performance Optimization Toolkit scripts. The test suite provides validation for the performance scripts to ensure they function correctly across different environments.

## Overview

The test suite uses a mock environment approach to validate script behavior without making actual changes to your system. It creates temporary test directories and files, mocks system commands, and verifies script outputs.

## Running Tests

The test suite provides a unified test runner with various options:

```bash
cd .vscode/performance/tests
./run_tests.sh [options] [test_files]
```

### Options

- `-h, --help` - Show help message
- `-v, --verbose` - Show detailed test output
- `-r, --real` - Run with real environment (not mock - use with caution)
- `-c, --coverage` - Run simple coverage report after tests
- `-d, --detailed-coverage` - Run detailed HTML coverage report after tests

### Examples

Run all tests with mock environment:

```bash
./run_tests.sh
```

Run a specific test:

```bash
./run_tests.sh test_monitor.sh
```

Run all tests and generate a simple coverage report:

```bash
./run_tests.sh -c
```

Run all tests and generate a detailed HTML coverage report:

```bash
./run_tests.sh -d
```

### Legacy Commands

The following legacy commands are still supported but deprecated:

```bash
# Old test runner (creates mock environment)
bash test_runner.sh

# Run tests one by one with result tracking
bash run_all_tests.sh
```

## Test Structure

- **test_runner.sh**: Main test runner that executes all tests
- **test_utils.sh**: Common utilities and helper functions for tests
- **test\_\*\_script.sh**: Individual test files for each performance script

## Adding New Tests

To add a test for a new script:

1. Create a new file named `test_yourscript.sh` in this directory
2. Source the `test_utils.sh` file at the beginning
3. Create test functions for each functionality you want to test
4. Follow the pattern used in existing tests
5. Make sure your test cleans up after itself

## Mock Environment

The test suite creates a mock environment in `tests/mocks` with:

- Mock Cursor config directories
- Mock extension directories
- Mock processes
- Mock settings files

This approach ensures tests can be run safely without affecting your actual Cursor installation.

## Skip Mechanism

If a test should be skipped in certain environments, create a file named `test_yourscript.sh.skip` with an explanation inside. The test runner will automatically skip tests with corresponding .skip files.

## Test Coverage

Currently, the test suite covers:

- Cleanup script (cache cleanup, settings backup)
- Extension manager (listing, enabling, disabling)
- Performance dashboard (menu options, process detection, cache detection)
- Performance monitor (process monitoring, resource usage display)

All performance optimization scripts now have corresponding tests, providing comprehensive coverage of the toolkit's functionality.

## Coverage Analysis

The test suite includes two coverage analysis tools:

1. **Simple Coverage Report** - Quick text-based summary in the terminal:

```bash
cd .vscode/performance/tests
bash simple_coverage_report.sh
```

2. **Detailed Coverage Analysis** - Generates an HTML report with detailed metrics:

```bash
cd .vscode/performance/tests
bash coverage_tracker.sh
```

The coverage tracker analyzes:

1. **Function Coverage**: Which functions in each script are tested
2. **Feature Coverage**: Which key features (like cache management, extension handling) are tested

The tool generates an HTML report at `tests/coverage/coverage_report.html` with:

- Overall coverage summary with progress bars
- Per-script detailed coverage information
- Lists of covered and uncovered functions and features

This helps identify gaps in testing and prioritize where to add new tests.

## Contributing

When adding new performance scripts, please also add corresponding tests to ensure functionality is maintained across updates.
