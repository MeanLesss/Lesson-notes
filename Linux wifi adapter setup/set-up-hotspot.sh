#!/bin/bash

set -e

# Function to prompt user for input
choose_input() {
  local prompt="$1"
  local iface
  while true; do
    read -p "$prompt" iface
    if [[ -z "$iface" ]]; then
      echo "Input cannot be empty. Please provide a valid interface name."
    else
      echo "$iface"
      return
    fi
  done
}

# Function to list Ethernet and Wi-Fi interfaces
list_interfaces() {
  echo "=== Available Interfaces ==="
  
  echo "Ethernet interfaces:"
  ip -o link show | awk -F': ' '{print $2}' | grep -E 'eth|enx'

  echo "Wi-Fi interfaces:"
  iw dev | grep 'Interface' | awk '{print $2}'
}

# Install Required Packages
install_packages() {
  echo "[+] Installing required packages..."
  apt update
  apt install -y hostapd dnsmasq iptables-persistent
  echo "[+] Package installation complete."
}

# Setup Hotspot
setup_hotspot() {
  echo "=== Raspberry Pi Hotspot Setup ==="

  ETH_IFACE=$(choose_input "Enter the name of your Ethernet interface (internet source): ")
  WIFI_IFACE=$(choose_input "Enter the name of your Wi-Fi interface (for hotspot): ")

  echo
  echo "You have selected:"
  echo "Ethernet interface: $ETH_IFACE"
  echo "Wi-Fi interface: $WIFI_IFACE"
  echo

  read -p "Enter Hotspot SSID: " SSID
  read -s -p "Enter Hotspot Password (min 8 chars): " PASS
  echo

  if [ ${#PASS} -lt 8 ]; then
    echo "Password must be at least 8 characters."
    exit 1
  fi

  echo
  echo "Configuration complete."
  read -p "Do you want to proceed with the setup? (y/n): " confirm
  if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "Exiting script. No changes were made."
    exit 0
  fi

  echo "[+] Configuring static IP for $WIFI_IFACE..."
  if ! grep -q "$WIFI_IFACE" /etc/dhcpcd.conf; then
    cat <<EOF >> /etc/dhcpcd.conf

interface $WIFI_IFACE
    static ip_address=192.168.4.1/24
    nohook wpa_supplicant
EOF
  fi

  echo "[+] Writing dnsmasq config..."
  cat <<EOF > /etc/dnsmasq.conf
interface=$WIFI_IFACE
dhcp-range=192.168.4.2,192.168.4.20,255.255.255.0,24h
server=8.8.8.8
EOF

  echo "[+] Writing hostapd config..."
  cat <<EOF > /etc/hostapd/hostapd.conf
interface=$WIFI_IFACE
driver=nl80211
ssid=$SSID
hw_mode=g
channel=6
wmm_enabled=0
auth_algs=1
wpa=2
wpa_passphrase=$PASS
wpa_key_mgmt=WPA-PSK
rsn_pairwise=CCMP
EOF

  echo 'DAEMON_CONF="/etc/hostapd/hostapd.conf"' > /etc/default/hostapd

  echo "[+] Enabling IP forwarding..."
  sed -i '/^#net.ipv4.ip_forward=1/s/^#//' /etc/sysctl.conf
  sysctl -w net.ipv4.ip_forward=1

  echo "[+] Setting up NAT from $WIFI_IFACE to $ETH_IFACE..."
  iptables -t nat -A POSTROUTING -o $ETH_IFACE -j MASQUERADE
  iptables -A FORWARD -i $ETH_IFACE -o $WIFI_IFACE -m state --state RELATED,ESTABLISHED -j ACCEPT
  iptables -A FORWARD -i $WIFI_IFACE -o $ETH_IFACE -j ACCEPT
  netfilter-persistent save

  echo "[+] Restarting services..."
  systemctl restart dhcpcd
  systemctl restart dnsmasq
  systemctl unmask hostapd
  systemctl enable hostapd
  systemctl restart hostapd

  echo
  echo "=== Hotspot setup complete! ==="
  echo "SSID: $SSID"
  echo "Password: $PASS"
}

# Reset Hotspot
reset_hotspot() {
  echo "[!] Resetting hotspot setup..."

  sed -i '/interface .*$/,+2d' /etc/dhcpcd.conf
  rm -f /etc/dnsmasq.conf
  rm -f /etc/hostapd/hostapd.conf
  echo 'DAEMON_CONF=""' > /etc/default/hostapd

  iptables -F
  iptables -t nat -F
  netfilter-persistent save

  systemctl restart dhcpcd
  systemctl restart dnsmasq
  systemctl stop hostapd
  systemctl disable hostapd

  echo "[+] Hotspot reset complete."
}

# Turn on Hotspot
turn_on_hotspot() {
  echo "[+] Turning on the hotspot..."
  systemctl start hostapd
  systemctl start dnsmasq
  echo "[+] Hotspot is now running."
}

# Turn off Hotspot
turn_off_hotspot() {
  echo "[+] Turning off the hotspot..."
  systemctl stop hostapd
  systemctl stop dnsmasq
  echo "[+] Hotspot is now stopped."
}

# Enable Hotspot on Boot
enable_on_startup() {
  echo "[+] Enabling hotspot to start on boot..."
  systemctl enable hostapd
  systemctl enable dnsmasq
  echo "[+] Hotspot is now set to start on boot."
}

# Fix Interface IP
fix_hotspot_interface() {
  echo "=== Fix Hotspot Interface (Manual IP Assignment) ==="
  list_interfaces

  local iface
  iface=$(choose_input "Enter the interface name to fix (Wi-Fi dongle for hotspot): ")

  echo "[+] Fixing $iface..."

  ip link set "$iface" down
  ip addr flush dev "$iface"
  ip addr add 192.168.4.1/24 dev "$iface"
  ip link set "$iface" up

  echo
  echo "[+] Static IP 192.168.4.1/24 has been assigned to $iface"
  ip a show "$iface"
}

# Main Menu
while true; do
  echo
  echo "========== Pi Hotspot Tool =========="
  echo "1) Install Required Packages"
  echo "2) Set up Wi-Fi Hotspot"
  echo "3) Reset / Remove Hotspot"
  echo "4) List Ethernet and Wi-Fi Interfaces"
  echo "5) Turn On Hotspot"
  echo "6) Turn Off Hotspot"
  echo "7) Set Hotspot to Start on Boot"
  echo "8) Exit"
  echo "9) Fix Hotspot Interface (Assign Static IP Manually)"
  read -p "Select an option [1-9]: " choice

  case $choice in
    1) install_packages ;;
    2) setup_hotspot ;;
    3) reset_hotspot ;;
    4) list_interfaces ;;
    5) turn_on_hotspot ;;
    6) turn_off_hotspot ;;
    7) enable_on_startup ;;
    8) echo "Bye!"; exit 0 ;;
    9) fix_hotspot_interface ;;
    *) echo "Invalid option. Try again." ;;
  esac
done
