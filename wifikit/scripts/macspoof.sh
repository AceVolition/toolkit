#!/bin/bash

IFACE="wlan0"

# Must be root
if [[ $EUID -ne 0 ]]; then
    echo "[!] Run as root."
    exit 1
fi

# Check if interface exists
if ! ip link show "$IFACE" &>/dev/null; then
    echo "[!] Interface $IFACE not found."
    exit 1
fi

# Make sure interface is down before spoofing
echo "[*] Bringing down $IFACE..."
ip link set "$IFACE" down

# Spoof MAC
echo "[*] Spoofing MAC for $IFACE..."
macchanger -r "$IFACE"

# Bring interface back up
echo "[*] Bringing up $IFACE..."
ip link set "$IFACE" up

# Show result
macchanger -s "$IFACE"

