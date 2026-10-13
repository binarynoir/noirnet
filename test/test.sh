#!/usr/bin/env bash

# Test suite for NoirNet
# Uses stub ping and nslookup commands to simulate outages, plus one real ping to localhost.
# Requires bash 4.3+ and the NoirNet dependencies.
# Usage: ./test/test.sh

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP="$SCRIPT_DIR/../noirnet"
WORK_DIR="$(mktemp -d)"
CONFIG="$WORK_DIR/config.json"
CACHE="$WORK_DIR/cache"
PASSED=0
FAILED=0

# Function: Remove test artifacts
cleanup() {
    "$APP" -c "$CONFIG" --stop >/dev/null 2>&1
    rm -rf "$WORK_DIR"
}
trap cleanup EXIT

# Function: Run the app and capture its output and exit code
run() {
    OUTPUT=$("$APP" "$@" 2>&1 </dev/null)
    STATUS=$?
}

# Function: Record a passing or failing assertion
check() {
    local description="$1"
    shift
    if "$@"; then
        PASSED=$((PASSED + 1))
        printf "  ok   %s\n" "$description"
    else
        FAILED=$((FAILED + 1))
        printf "  FAIL %s\n" "$description"
        printf "       exit code: %s\n" "${STATUS:-n/a}"
        printf "%s\n" "${OUTPUT:-}" | sed 's/^/       | /' | head -20
    fi
}

status_is() { [[ "$STATUS" -eq "$1" ]]; }
output_has() { [[ "$OUTPUT" == *"$1"* ]]; }
output_lacks() { [[ "$OUTPUT" != *"$1"* ]]; }
json_true() { jq -e "$1" "$2" >/dev/null; }

# Function: Count the outage rows in a CSV file, excluding the header
outage_rows() {
    tail -n +2 "$CACHE/$1" | grep -c .
}

cat >"$CONFIG" <<EOF
{
    "configuration": {
        "CACHE_DIR": "$CACHE",
        "LOG_FILE": "$CACHE/noirnet.log",
        "CHECK_INTERVAL": "1s",
        "TIMEOUT": "1s",
        "PING_TARGET": "127.0.0.1",
        "DNS_TEST_DOMAIN": "example.com"
    }
}
EOF

# Stub commands that replay a sequence of up/down results, one per call
mkdir -p "$WORK_DIR/stubs"
for stub in ping nslookup; do
    cat >"$WORK_DIR/stubs/$stub" <<EOF
#!/usr/bin/env bash
state_file="$WORK_DIR/$stub.states"
state=\$(head -n 1 "\$state_file")
tail -n +2 "\$state_file" >"\$state_file.next" && mv "\$state_file.next" "\$state_file"
[[ "\$state" == up ]]
EOF
    chmod +x "$WORK_DIR/stubs/$stub"
done

echo "Command line"
run --help
check "--help exits 0" status_is 0
check "--help shows usage" output_has "Usage:"
run --version
check "--version shows the version" output_has "version:"
run --bogus
check "unknown options are rejected" status_is 1
run stray-argument
check "stray arguments are rejected" status_is 1
run -c "$CONFIG" --ping-target 'host;id' -S
check "invalid ping targets are rejected" status_is 1
run -c "$CONFIG" --dns-test-domain 'a b' -S
check "invalid DNS test domains are rejected" status_is 1

echo "Configuration"
run --init -c "$WORK_DIR/init.json" -C "$CACHE"
check "--init creates a configuration file" status_is 0
check "the generated configuration is valid JSON" json_true '.configuration.PING_TARGET == "8.8.8.8"' "$WORK_DIR/init.json"
run -c "$CONFIG" -S
check "settings come from the configuration file" output_has "Ping target: 127.0.0.1"

echo "Connectivity"
run -c "$CONFIG" -N 1 -L DEBUG
check "a real ping to localhost reports the network as up" output_has "Network is up"
check "the CSV history files are created" test -f "$CACHE/network_downtime.csv" -a -f "$CACHE/dns_downtime.csv"

printf "%s\n" down up up >"$WORK_DIR/ping.states"
printf "%s\n" down up >"$WORK_DIR/nslookup.states"
OUTPUT=$(PATH="$WORK_DIR/stubs:$PATH" "$APP" -c "$CONFIG" -N 3 2>&1 </dev/null)
STATUS=$?
check "a simulated outage run completes" status_is 0
check "a network outage is reported" output_has "network is down"
check "the network recovery is reported" output_has "network is back online after"
check "the network outage is recorded" test "$(outage_rows network_downtime.csv)" -eq 1
check "a DNS outage is reported" output_has "DNS resolution failed"
check "the DNS recovery is reported" output_has "DNS resolution is back after"
check "the DNS outage is recorded" test "$(outage_rows dns_downtime.csv)" -eq 1

echo "Service management"
run -c "$CONFIG" --status
check "--status exits 3 when stopped" status_is 3
run -c "$CONFIG" --start
check "--start starts the service" status_is 0
run -c "$CONFIG" --status
check "--status exits 0 when running" status_is 0
run -c "$CONFIG" --stop
check "--stop stops the service" output_has "service stopped"
check "--stop removes the PID file" test ! -f "$CACHE/noirnet.pid"

printf "\n%d passed, %d failed\n" "$PASSED" "$FAILED"
[[ "$FAILED" -eq 0 ]]
