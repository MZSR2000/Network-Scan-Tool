#!/bin/bash

discover_devices() {
    echo "Discovering devices on the local network..."
    read -p "Enter the subnet (e.g., 192.168.1): " subnet
    for ip in {1..254}; do
        ping -c 1 -W 1 $subnet.$ip &> /dev/null && echo "Device found at: $subnet.$ip" &
    done
    wait
    echo "Discovery complete."
}

scan_ports() {
    echo "Scanning ports on a remote host..."
    read -p "Enter the IP address of the host: " host
    read -p "Enter the range of ports to scan (e.g., 1-1000 or specific ports like 22,80,443): " ports

    # If the user enters a range
    if [[ $ports =~ ^[0-9]+-[0-9]+$ ]]; then
        IFS='-' read -r start_port end_port <<< "$ports"
        for (( port=$start_port; port<=$end_port; port++ )); do
            (echo >/dev/tcp/$host/$port) &> /dev/null && echo "Port $port is open" &
        done

    # If the user enters specific ports
    elif [[ $ports =~ ^[0-9,]+$ ]]; then
        IFS=',' read -r -a port_array <<< "$ports"
        for port in "${port_array[@]}"; do
            (echo >/dev/tcp/$host/$port) &> /dev/null && echo "Port $port is open" &
        done
    else
        echo "Invalid port format. Please use a range (e.g., 1-1000) or specific ports (e.g., 22,80,443)."
    fi
    wait
    echo "Port scan complete."
}

echo "Choose an option:"
echo "1) Discover devices on the local network"
echo "2) Scan open ports on a remote host"
read -p "Enter your choice (1 or 2): " choice

case $choice in
    1)
        discover_devices
        ;;
    2)
        scan_ports
        ;;
    *)
        echo "Invalid choice. Please select 1 or 2."
        ;;
esac

