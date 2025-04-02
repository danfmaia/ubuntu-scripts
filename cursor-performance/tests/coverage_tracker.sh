#!/bin/bash

# Cursor Performance Scripts Coverage Tracker
# Analyzes which functions and features are covered by tests

# Terminal colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PERF_DIR="$(dirname "${SCRIPT_DIR}")"
COVERAGE_DIR="${SCRIPT_DIR}/coverage"

# Scripts to analyze
SCRIPTS=(
    "cursor-cleanup-safe.sh"
    "cursor-disable-extensions.sh"
    "cursor-monitor.sh"
    "cursor-performance-dashboard.sh"
)

# Initialize coverage tracking
init_coverage() {
    # Create coverage directory
    mkdir -p "${COVERAGE_DIR}"
    rm -f "${COVERAGE_DIR}"/*.cov
}

# Extract functions from a script
extract_functions() {
    local script="$1"
    local output_file="${COVERAGE_DIR}/$(basename "$script" .sh).functions"
    
    # Extract function definitions using regex
    grep -E '^[[:space:]]*(function[[:space:]]+[a-zA-Z0-9_]+[[:space:]]*\(\)|[a-zA-Z0-9_]+[[:space:]]*\(\))' "${PERF_DIR}/${script}" | 
        sed -E 's/^[[:space:]]*(function[[:space:]]+|)([a-zA-Z0-9_]+).*$/\2/g' > "${output_file}"
    
    echo "${output_file}"
}

# Identify key features in a script that should be tested
extract_features() {
    local script="$1"
    local output_file="${COVERAGE_DIR}/$(basename "$script" .sh).features"
    
    # Initialize features file
    > "${output_file}"
    
    # Common features to check for
    if grep -q "read -r choice" "${PERF_DIR}/${script}"; then
        echo "user_input_handling" >> "${output_file}"
    fi
    
    if grep -q "pgrep" "${PERF_DIR}/${script}"; then
        echo "process_detection" >> "${output_file}"
    fi
    
    if grep -q "du -sh" "${PERF_DIR}/${script}"; then
        echo "disk_space_analysis" >> "${output_file}"
    fi
    
    if grep -q "free -h" "${PERF_DIR}/${script}"; then
        echo "memory_analysis" >> "${output_file}"
    fi
    
    if grep -q "settings.json" "${PERF_DIR}/${script}"; then
        echo "settings_handling" >> "${output_file}"
    fi
    
    if grep -q "\.cursor/extensions" "${PERF_DIR}/${script}"; then
        echo "extension_management" >> "${output_file}"
    fi
    
    if grep -q "CachedData" "${PERF_DIR}/${script}"; then
        echo "cache_management" >> "${output_file}"
    fi
    
    if grep -q "xdg-open" "${PERF_DIR}/${script}"; then
        echo "file_opening" >> "${output_file}"
    fi
    
    if grep -q "code --" "${PERF_DIR}/${script}"; then
        echo "vscode_cli_integration" >> "${output_file}"
    fi
    
    echo "${output_file}"
}

# Check which functions are covered by tests
analyze_function_coverage() {
    local script="$1"
    local base_name=$(basename "$script" .sh)
    local functions_file="${COVERAGE_DIR}/${base_name}.functions"
    local test_file="${SCRIPT_DIR}/test_${base_name}.sh"
    local coverage_file="${COVERAGE_DIR}/${base_name}.coverage"
    
    # Initialize coverage file
    > "${coverage_file}"
    
    # Handle special test file name cases
    if [[ "$base_name" == "cursor-cleanup-safe" && -f "${SCRIPT_DIR}/test_cleanup_script.sh" ]]; then
        test_file="${SCRIPT_DIR}/test_cleanup_script.sh"
    elif [[ "$base_name" == "cursor-disable-extensions" && -f "${SCRIPT_DIR}/test_extension_manager.sh" ]]; then
        test_file="${SCRIPT_DIR}/test_extension_manager.sh"
    elif [[ "$base_name" == "cursor-performance-dashboard" && -f "${SCRIPT_DIR}/test_performance_dashboard.sh" ]]; then
        test_file="${SCRIPT_DIR}/test_performance_dashboard.sh"
    elif [[ "$base_name" == "cursor-monitor" && -f "${SCRIPT_DIR}/test_monitor.sh" ]]; then
        test_file="${SCRIPT_DIR}/test_monitor.sh"
    fi
    
    # Check if test exists
    if [[ ! -f "${test_file}" ]]; then
        echo -e "${RED}No test found for ${script}${NC}"
        
        # Mark all functions as uncovered
        while read -r function_name; do
            echo "${function_name},UNCOVERED" >> "${coverage_file}"
        done < "${functions_file}"
        
        return
    fi
    
    # For each function in the script, check if it's referenced in the test
    while read -r function_name; do
        if grep -q "${function_name}" "${test_file}"; then
            echo "${function_name},COVERED" >> "${coverage_file}"
        else
            echo "${function_name},UNCOVERED" >> "${coverage_file}"
        fi
    done < "${functions_file}"
}

# Check which features are covered by tests
analyze_feature_coverage() {
    local script="$1"
    local base_name=$(basename "$script" .sh)
    local features_file="${COVERAGE_DIR}/${base_name}.features"
    local test_file="${SCRIPT_DIR}/test_${base_name}.sh"
    local feature_coverage="${COVERAGE_DIR}/${base_name}.feature_coverage"
    
    # Initialize feature coverage file
    > "${feature_coverage}"
    
    # Handle special test file name cases
    if [[ "$base_name" == "cursor-cleanup-safe" && -f "${SCRIPT_DIR}/test_cleanup_script.sh" ]]; then
        test_file="${SCRIPT_DIR}/test_cleanup_script.sh"
    elif [[ "$base_name" == "cursor-disable-extensions" && -f "${SCRIPT_DIR}/test_extension_manager.sh" ]]; then
        test_file="${SCRIPT_DIR}/test_extension_manager.sh"
    elif [[ "$base_name" == "cursor-performance-dashboard" && -f "${SCRIPT_DIR}/test_performance_dashboard.sh" ]]; then
        test_file="${SCRIPT_DIR}/test_performance_dashboard.sh"
    elif [[ "$base_name" == "cursor-monitor" && -f "${SCRIPT_DIR}/test_monitor.sh" ]]; then
        test_file="${SCRIPT_DIR}/test_monitor.sh"
    fi
    
    # Check if test exists
    if [[ ! -f "${test_file}" ]]; then
        # Mark all features as uncovered
        while read -r feature; do
            echo "${feature},UNCOVERED" >> "${feature_coverage}"
        done < "${features_file}"
        
        return
    fi
    
    # For each feature, check if it's likely covered in the test
    while read -r feature; do
        case "${feature}" in
            user_input_handling)
                if grep -q "read -r choice" "${test_file}" || grep -q "choice=" "${test_file}"; then
                    echo "${feature},COVERED" >> "${feature_coverage}"
                else
                    echo "${feature},UNCOVERED" >> "${feature_coverage}"
                fi
                ;;
            process_detection)
                if grep -q "pgrep" "${test_file}" || grep -q "mock_pgrep" "${test_file}"; then
                    echo "${feature},COVERED" >> "${feature_coverage}"
                else
                    echo "${feature},UNCOVERED" >> "${feature_coverage}"
                fi
                ;;
            disk_space_analysis)
                if grep -q "du -sh" "${test_file}" || grep -q "mock_du" "${test_file}"; then
                    echo "${feature},COVERED" >> "${feature_coverage}"
                else
                    echo "${feature},UNCOVERED" >> "${feature_coverage}"
                fi
                ;;
            memory_analysis)
                if grep -q "free -h" "${test_file}" || grep -q "mock_free" "${test_file}"; then
                    echo "${feature},COVERED" >> "${feature_coverage}"
                else
                    echo "${feature},UNCOVERED" >> "${feature_coverage}"
                fi
                ;;
            settings_handling)
                if grep -q "settings.json" "${test_file}"; then
                    echo "${feature},COVERED" >> "${feature_coverage}"
                else
                    echo "${feature},UNCOVERED" >> "${feature_coverage}"
                fi
                ;;
            extension_management)
                if grep -q "\.cursor/extensions" "${test_file}" || grep -q "extensions" "${test_file}"; then
                    echo "${feature},COVERED" >> "${feature_coverage}"
                else
                    echo "${feature},UNCOVERED" >> "${feature_coverage}"
                fi
                ;;
            cache_management)
                if grep -q "CachedData" "${test_file}" || grep -q "cache" "${test_file}"; then
                    echo "${feature},COVERED" >> "${feature_coverage}"
                else
                    echo "${feature},UNCOVERED" >> "${feature_coverage}"
                fi
                ;;
            file_opening)
                if grep -q "xdg-open" "${test_file}" || grep -q "open" "${test_file}"; then
                    echo "${feature},COVERED" >> "${feature_coverage}"
                else
                    echo "${feature},UNCOVERED" >> "${feature_coverage}"
                fi
                ;;
            vscode_cli_integration)
                if grep -q "code --" "${test_file}" || grep -q "mock.*code" "${test_file}"; then
                    echo "${feature},COVERED" >> "${feature_coverage}"
                else
                    echo "${feature},UNCOVERED" >> "${feature_coverage}"
                fi
                ;;
            *)
                echo "${feature},UNKNOWN" >> "${feature_coverage}"
                ;;
        esac
    done < "${features_file}"
}

# Generate coverage HTML report
generate_report() {
    local report_file="${COVERAGE_DIR}/coverage_report.html"
    
    # Initialize HTML report
    cat > "${report_file}" << EOF
<!DOCTYPE html>
<html>
<head>
    <title>Cursor Performance Scripts Coverage Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        h1 { color: #333; }
        h2 { color: #444; margin-top: 30px; }
        table { border-collapse: collapse; width: 100%; margin-top: 10px; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
        tr:nth-child(even) { background-color: #f9f9f9; }
        .covered { color: green; }
        .uncovered { color: red; }
        .summary { font-weight: bold; margin: 15px 0; }
        .progress-container { width: 100%; background-color: #f1f1f1; border-radius: 5px; }
        .progress-bar { height: 20px; border-radius: 5px; }
        .progress-covered { background-color: #4CAF50; }
        .progress-uncovered { background-color: #f44336; }
    </style>
</head>
<body>
    <h1>Cursor Performance Scripts Coverage Report</h1>
    <p>Generated on $(date)</p>
EOF
    
    # Add overall summary
    local total_functions=0
    local covered_functions=0
    local total_features=0
    local covered_features=0
    
    for script in "${SCRIPTS[@]}"; do
        local base_name=$(basename "${script}" .sh)
        local function_coverage="${COVERAGE_DIR}/${base_name}.coverage"
        local feature_coverage="${COVERAGE_DIR}/${base_name}.feature_coverage"
        
        # Count functions
        if [[ -f "${function_coverage}" ]]; then
            local script_total=$(wc -l < "${function_coverage}")
            local script_covered=$(grep "COVERED" "${function_coverage}" | wc -l)
            
            total_functions=$((total_functions + script_total))
            covered_functions=$((covered_functions + script_covered))
        fi
        
        # Count features
        if [[ -f "${feature_coverage}" ]]; then
            local feature_total=$(wc -l < "${feature_coverage}")
            local feature_covered=$(grep "COVERED" "${feature_coverage}" | wc -l)
            
            total_features=$((total_features + feature_total))
            covered_features=$((covered_features + feature_covered))
        fi
    done
    
    # Calculate percentages
    local function_percentage=0
    if [[ ${total_functions} -gt 0 ]]; then
        function_percentage=$((covered_functions * 100 / total_functions))
    fi
    
    local feature_percentage=0
    if [[ ${total_features} -gt 0 ]]; then
        feature_percentage=$((covered_features * 100 / total_features))
    fi
    
    # Add summary to report
    cat >> "${report_file}" << EOF
    <h2>Overall Coverage Summary</h2>
    
    <div class="summary">Function Coverage: ${covered_functions}/${total_functions} (${function_percentage}%)</div>
    <div class="progress-container">
        <div class="progress-bar progress-covered" style="width:${function_percentage}%"></div>
    </div>
    
    <div class="summary">Feature Coverage: ${covered_features}/${total_features} (${feature_percentage}%)</div>
    <div class="progress-container">
        <div class="progress-bar progress-covered" style="width:${feature_percentage}%"></div>
    </div>
    
    <h2>Detailed Coverage by Script</h2>
EOF
    
    # Add per-script coverage
    for script in "${SCRIPTS[@]}"; do
        local base_name=$(basename "${script}" .sh)
        local function_coverage="${COVERAGE_DIR}/${base_name}.coverage"
        local feature_coverage="${COVERAGE_DIR}/${base_name}.feature_coverage"
        
        cat >> "${report_file}" << EOF
    <h3>${script}</h3>
EOF
        
        # Check if test exists
        if [[ ! -f "${SCRIPT_DIR}/test_${base_name}.sh" ]]; then
            cat >> "${report_file}" << EOF
    <p class="uncovered">No test found for this script</p>
EOF
        else
            cat >> "${report_file}" << EOF
    <p>Test file: <code>test_${base_name}.sh</code></p>
EOF
        fi
        
        # Add function coverage table
        if [[ -f "${function_coverage}" ]]; then
            local script_total=$(wc -l < "${function_coverage}")
            local script_covered=$(grep "COVERED" "${function_coverage}" | wc -l)
            local script_percentage=0
            
            if [[ ${script_total} -gt 0 ]]; then
                script_percentage=$((script_covered * 100 / script_total))
            fi
            
            cat >> "${report_file}" << EOF
    <div class="summary">Function Coverage: ${script_covered}/${script_total} (${script_percentage}%)</div>
    <div class="progress-container">
        <div class="progress-bar progress-covered" style="width:${script_percentage}%"></div>
    </div>
    
    <table>
        <tr>
            <th>Function</th>
            <th>Coverage</th>
        </tr>
EOF
            
            while IFS=, read -r function_name status; do
                if [[ "${status}" == "COVERED" ]]; then
                    cat >> "${report_file}" << EOF
        <tr>
            <td>${function_name}</td>
            <td class="covered">✓ Covered</td>
        </tr>
EOF
                else
                    cat >> "${report_file}" << EOF
        <tr>
            <td>${function_name}</td>
            <td class="uncovered">✗ Not covered</td>
        </tr>
EOF
                fi
            done < "${function_coverage}"
            
            cat >> "${report_file}" << EOF
    </table>
EOF
        fi
        
        # Add feature coverage table
        if [[ -f "${feature_coverage}" ]]; then
            local feature_total=$(wc -l < "${feature_coverage}")
            local feature_covered=$(grep "COVERED" "${feature_coverage}" | wc -l)
            local feature_percentage=0
            
            if [[ ${feature_total} -gt 0 ]]; then
                feature_percentage=$((feature_covered * 100 / feature_total))
            fi
            
            cat >> "${report_file}" << EOF
    <div class="summary">Feature Coverage: ${feature_covered}/${feature_total} (${feature_percentage}%)</div>
    <div class="progress-container">
        <div class="progress-bar progress-covered" style="width:${feature_percentage}%"></div>
    </div>
    
    <table>
        <tr>
            <th>Feature</th>
            <th>Coverage</th>
        </tr>
EOF
            
            while IFS=, read -r feature status; do
                if [[ "${status}" == "COVERED" ]]; then
                    cat >> "${report_file}" << EOF
        <tr>
            <td>${feature}</td>
            <td class="covered">✓ Covered</td>
        </tr>
EOF
                else
                    cat >> "${report_file}" << EOF
        <tr>
            <td>${feature}</td>
            <td class="uncovered">✗ Not covered</td>
        </tr>
EOF
                fi
            done < "${feature_coverage}"
            
            cat >> "${report_file}" << EOF
    </table>
EOF
        fi
    done
    
    # Close HTML document
    cat >> "${report_file}" << EOF
    <hr>
    <p>Report generated by Cursor Performance Scripts Coverage Tracker</p>
</body>
</html>
EOF
    
    echo "${report_file}"
}

# Run the coverage analysis
run_coverage_analysis() {
    # Initialize
    init_coverage
    
    # Process each script
    for script in "${SCRIPTS[@]}"; do
        echo -e "${BLUE}Analyzing coverage for ${script}...${NC}"
        
        # Extract functions and features
        extract_functions "${script}"
        extract_features "${script}"
        
        # Analyze coverage
        analyze_function_coverage "${script}"
        analyze_feature_coverage "${script}"
    done
    
    # Generate report
    local report_file=$(generate_report)
    
    echo -e "\n${GREEN}Coverage analysis complete!${NC}"
    echo -e "Report generated at: ${report_file}"
    
    # Try to open the report
    if command -v xdg-open &> /dev/null; then
        xdg-open "${report_file}"
    elif command -v open &> /dev/null; then
        open "${report_file}"
    else
        echo -e "${YELLOW}Please open the report manually${NC}"
    fi
}

# Main execution
run_coverage_analysis 