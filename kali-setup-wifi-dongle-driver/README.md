# Installing TP-Link Archer AC600 (T2U) Driver on Kali Linux

This guide covers installing drivers for the TP-Link AC600 / T2U series on Kali Linux.  
The T2U name is used for multiple hardware revisions, so the **first step** is to identify your chipset.

---

## 1. Identify Your Adapter's Chipset

Run:
```bash
lsusb
```
Common results:

| Chipset | USB ID Example | Notes |
|---------|----------------|-------|
| **Realtek RTL8811AU / RTL8821AU** | `2357:0120` or shows as "Realtek Semiconductor Corp." | Requires DKMS driver |
| **MediaTek MT7610U** | `0e8d:7610` or `148f:761a` | Supported by in-kernel `mt76` driver |

---

## 2. Realtek RTL8811AU / RTL8821AU (T2U Plus, T2U Nano)

### 2.1 Install Build Tools & Headers
```bash
sudo apt update
sudo apt install -y dkms build-essential linux-headers-$(uname -r)
```

### 2.2 Clean Up Old/Broken Driver Installations
```bash
sudo apt purge realtek-rtl88xxau-dkms
sudo rm -rf /usr/src/rtl88xxau*
```

### 2.3 Install the Realtek DKMS Driver
```bash
sudo apt install realtek-rtl88xxau-dkms
```

> **Note:** During install, you should see:
> ```
> Building for 6.x.x-kali-amd64
> Module build for kernel 6.x.x was successful
> ```

If you see errors, check:
```bash
cat /var/lib/dkms/rtl88xxau/*/build/make.log
```

### 2.4 Load the Driver
```bash
sudo modprobe 88XXau
```

### 2.5 Verify Interface
```bash
ip link
```

### 2.6 (Optional) Enable Monitor Mode
```bash
sudo ip link set wlan0 down
sudo iw dev wlan0 set type monitor
sudo ip link set wlan0 up
```
### `Changing change and type`
```bash
sudo ip link set wlan0 down
sudo iw dev wlan0 set type monitor
sudo ip link set wlan0 up
sudo iw dev wlan0 set channel 36

```
---

## 3. MediaTek MT7610U (Original T2U, T2UH)

This chipset is supported by the **in-kernel** `mt76` driver and usually works out of the box.

### 3.1 Check If It Works
Plug in the adapter and run:
```bash
ip link
```
If you see `wlan0` or another `wlanX`, it’s ready to use.

### 3.2 If It Doesn’t Appear
Install firmware package:
```bash
sudo apt update
sudo apt install -y firmware-misc-nonfree
```
Replug the adapter and check:
```bash
dmesg | grep -i mt76
```

---

## 4. Troubleshooting

- **Module not found** (Realtek)  
  → Headers were missing when DKMS tried to build. Reinstall headers and the DKMS package.
- **DKMS build fails** (Realtek)  
  → Use a patched driver source from [Aircrack-ng rtl8812au repo](https://github.com/aircrack-ng/rtl8812au).
- **Adapter not detected**  
  → Verify chipset with `lsusb` and confirm correct driver path.

---

## 5. References

- Kali Linux Package: [`realtek-rtl88xxau-dkms`](https://pkg.kali.org/pkg/realtek-rtl88xxau-dkms)
- Realtek 88XXau DKMS (Aircrack-ng): [GitHub](https://github.com/aircrack-ng/rtl8812au)
- MediaTek `mt76` driver: [Linux Wireless wiki](https://wireless.wiki.kernel.org/en/users/drivers/mt76)

---
