#Set up Kali Linux wifi dongle for TP-Link AC600 T2U Driver Install 

1- Check if the usb is recognize by the system
```command
lsusb
```

2- Check the wireless/network component devices
```command
iwconfig
```

3- Install RealTek library
```command
sudo apt install realtek-rtl88xxau-dkms
```
