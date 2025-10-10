#!/bin/bash

# Configuration
WIRED_GW="{{ wired_gateway_ip }}"
LTE_GW="{{ lte_gateway_ip }}"
PING_HOST="8.8.8.8"
NODE3_IP="{{ hostvars['rpi-node3'].ansible_default_ipv4.address }}"
LOG_FILE="/var/log/route-switch.log"

# Log function
log_message() {
    local message="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $message" | tee -a "$LOG_FILE"
}

# Check if a gateway is reachable
check_route() {
    local gw=$1
    ping -c 2 -W 2 $gw >/dev/null 2>&1
    return $?
}

# Initialize the current interface
CURRENT_INTERFACE=""

while true; do
    if check_route $WIRED_GW; then
        if [ "$CURRENT_INTERFACE" != "wired" ]; then
            log_message "Switching to WIRED interface (Gateway: $WIRED_GW)"
            ip rule add from $NODE3_IP lookup wired priority 100
            ip rule del from $NODE3_IP lookup lte priority 200 2>/dev/null
            CURRENT_INTERFACE="wired"
        fi
    elif check_route $LTE_GW; then
        if [ "$CURRENT_INTERFACE" != "lte" ]; then
            log_message "Switching to LTE interface (Gateway: $LTE_GW)"
            ip rule add from $NODE3_IP lookup lte priority 200
            ip rule del from $NODE3_IP lookup wired priority 100 2>/dev/null
            CURRENT_INTERFACE="lte"
        fi
    else
        if [ "$CURRENT_INTERFACE" != "down" ]; then
            log_message "Both routes are down!"
            CURRENT_INTERFACE="down"
        fi
    fi
    sleep 5
done