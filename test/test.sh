#!/usr/bin/env bash

# Test script for NoirNet

# Default test configuration file and directories
DEFAULT_TEST_CONFIG_FILE="./test.json"
TEST_CACHE_DIR="./cache"
TEST_LOG_FILE="./test.log"

# Allow custom config file to be passed in
TEST_CONFIG_FILE="$DEFAULT_TEST_CONFIG_FILE"
CUSTOM_CONFIG_FILE=false
if [[ -n "$1" ]]; then
    TEST_CONFIG_FILE="$1"
    CUSTOM_CONFIG_FILE=true
fi

# Create a test configuration file
create_test_config() {
    if [[ "$CUSTOM_CONFIG_FILE" = false ]]; then
        cat <<EOF >"
    {
        "configuration": {
            "CACHE_DIR": "./test/cache/",
            "LOG_FILE": "./test/cache/test.log",
            "CHECK_INTERVAL": "60s",
            "TIMEOUT": "5s",
            "SYSTEM_NAME": "test system",
            "PUSHOVER_NOTIFICATION": "false",
            "PUSHOVER_USER_KEY": "",
            "PUSHOVER_API_TOKEN": "",
            "DESKTOP_NOTIFICATION": "true",
            "VERBOSE": "false",
            "LOG_LEVEL": "INFO",
            "PING_TARGET": "8.8.8.8",
            "DNS_TEST_DOMAIN: "example.com"
        }
    }
EOF
    fi
}

# Clean up test files and directories
cleanup() {
    rm -rf "$TEST_CACHE_DIR"
    rm -f "$TEST_LOG_FILE"
    if [[ "$CUSTOM_CONFIG_FILE" = false ]]; then
        rm -f "$TEST_CONFIG_FILE"
    fi
}

# Run tests
run_tests() {
    echo "Running tests..."

    # Test configuration initialization
    echo "Testing configuration initialization..."
    ./noirnet --init --config "$TEST_CONFIG_FILE"
    if [[ -f "$TEST_CONFIG_FILE" ]]; then
        echo "Configuration initialization: PASSED"
    else
        echo "Configuration initialization: FAILED"
    fi

    # Test cache directory creation
    echo "Testing cache directory creation..."
    ./noirnet --config "$TEST_CONFIG_FILE" --cache-dir "$TEST_CACHE_DIR"
    if [[ -d "$TEST_CACHE_DIR" ]]; then
        echo "Cache directory creation: PASSED"
    else
        echo "Cache directory creation: FAILED"
    fi

    # Test log file creation
    echo "Testing log file creation..."
    ./noirnet --config "$TEST_CONFIG_FILE" --log
    if [[ -f "$TEST_LOG_FILE" ]]; then
        echo "Log file creation: PASSED"
    else
        echo "Log file creation: FAILED"
    fi

    # Test network monitoring
    echo "Testing network monitoring..."
    ./noirnet --config "$TEST_CONFIG_FILE" --interval 1 --timeout 1 --start &
    sleep 5
    pkill -f "./noirnet --config $TEST_CONFIG_FILE --interval 1 --timeout 1 --start"
    if grep -q "Network is up" "$TEST_LOG_FILE"; then
        echo "Network monitoring: PASSED"
    else
        echo "Network monitoring: FAILED"
    fi

    # Clean up
    cleanup
}

# Main function
main() {
    create_test_config
    run_tests
}

# Run the main function
main
