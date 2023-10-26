function y2c() {
    # Convert YAML to CSV from stdin.

    # Check if python3 is installed
    if ! command -v python3 &> /dev/null; then
        echo "y2c: python3 is not installed"
        return 1
    fi

    # Check if PyYAML module is installed
    if ! python3 -c 'import yaml' &> /dev/null; then
        echo "y2c: PyYAML module is not installed"
        return 1
    fi

    # Check if input is from stdin
    if [[ -t 0 ]]; then
        echo "y2c: no input provided"
        return 1
    fi

    # Convert YAML to CSV and output to stdout
    python3 -c 'import sys, yaml, csv; csv.writer(sys.stdout).writerows(yaml.safe_load(sys.stdin.read()).items())'

}
