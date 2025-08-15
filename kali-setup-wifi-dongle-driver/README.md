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

4- Get System architecture name
```
uname -r
```

5- install header and builder
```
wget https://kali.download/kali/pool/main/l/linux/linux-headers-6.6.9-common_6.6.9-1kali1_all.deb
wget https://kali.download/kali/pool/main/l/linux/linux-kbuild-6.6.9_6.6.9-dbgsym_6.12.25-1kali1_amd64.deb
wget
```

6- Clone driver
```
git clone https://github.com/morrownr/8821au-20210708.git
```
