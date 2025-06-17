#!/bin/bash

# Root check
[ "$EUID" -ne 0 ] && { echo "Please run as root"; exit 1; }

while true; do
    clear
    echo "─────── WiFi Attack Toolkit ───────"
    echo "1) Deauth Attack"
    echo "2) MAC Spoofing"
    echo "3) Capture Wi-Fi Packets"
    echo "4) View Captures Folder"
    echo "5) Exit"
    echo "───────────────────────────────────"
    read -p "Choose an option [1-5]: " choice

    case $choice in
        1) bash ./scripts/deauth.sh ;;
        2) bash ./scripts/macspoof.sh ;;
        3) bash ./scripts/wificapture.sh ;;
        4)
            ls -lh ./wifia
            echo "1) Return"
            echo "2) Clean all files in capture folder"
            read -p "Choose an option [1-2]: " subchoice
            case $subchoice in
                1) ;;  # Return to main menu
                2)
                    rm -i ./wifia/*
                    echo "All files deleted from ./wifia"
                    ;;
                *)
                    echo "Invalid sub-option"
                    sleep 1
                    ;;
            esac
            ;;
        5) echo "Goodbye"; break ;;
        *) echo "Invalid option"; sleep 1 ;;
    esac
done

