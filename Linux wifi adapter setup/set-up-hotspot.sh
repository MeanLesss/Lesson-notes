#!/bin/bash

set -e

setup_hotspot() {
  echo "=== Raspberry Pi Hotspot Setup ==="
  read -p "Enter Ethernet interface (internet source, e.g. enx...): " ETH_IFACE
  read -p "Enter Wi-Fi interface (hotspot, e.g. wlx...): " WIFI_IFACE
  read -p "Enter Hotspot SSID: " SSID
  read -s -p "Enter Hotspot Password (min 8 chars): " PASS
  echo

  if [ ${#PASS} -lt 8 ]; then
    echo "Password must be at least 8 characters."
    exit 1
  fi

  echo "[+] Installing required packages..."
  apt update
  apt install -y hostapd dnsmasq iptables-persistent

  systemctl stop hostapd
  systemctl stop dnsmasq

  echo "[+] Configuring static IP for $WIFI_IFACE..."
  grep -q "$WIFI_IFACE" /etc/dhcpcd.conf || cat <<EOF >> /etc/dhcpcd.conf

interface $WIFI_IFACE
    static ip_address=192.168.4.1/24
    nohook wpa_supplicant
EOF

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

while true; do
  echo
  echo "========== Pi Hotspot Tool =========="
  echo "1) Set up Wi-Fi Hotspot"
  echo "2) Reset / Remove Hotspot"
  echo "3) Exit"
  read -p "Select an option [1-3]: " choice

  case $choice in
    1) setup_hotspot ;;
    2) reset_hotspot ;;
    3) echo "Bye!"; exit 0 ;;
    *) echo "Invalid option. Try again." ;;
  esac
done
