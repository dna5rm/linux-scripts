function y2j() {
# Convert YAML to JSON from stdin.

    # Check if python3 is installed
    if ! command -v python3 &> /dev/null; then
        echo "y2j: python3 is not installed"
        return 1
    fi

    # Check if PyYAML module is installed
    if ! python3 -c 'import yaml' &> /dev/null; then
        echo "y2j: PyYAML module is not installed"
        return 1
    fi

    # Check if input is from stdin
    if [[ -t 0 ]]; then
        echo "y2j: no input provided"
        return 1
    fi

    # Convert YAML to JSON and output to stdout
    python3 -c 'import sys, yaml, json; print(json.dumps(yaml.safe_load(sys.stdin.read()), indent=2))'

}
