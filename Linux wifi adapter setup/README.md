🔧 Setup Instructions
1. Update & Install Dependencies:

```
sudo apt update
sudo apt install python3-pip git dkms build-essential raspberrypi-kernel-headers
```

2. Install Python Requirements:

```
pip3 install -r requirements.txt
```
Run the Script:

```
python3 wifi_setup.py
```


To run the set up set-up-hotspot.sh

add executable permission:
```
chmod +x set-up-hotspot.sh
```

then run `set-up-hotspot.sh` as sudo since it need to read and check network interfaces and install packages
```
sudo ./set-up-hotspot.sh
```



then select option `1` to install all required packages then `4` show all network interfaces the `2` to set up your hotspot with the correct network interface for example you use the ethernet connection to connect to network and shared as hotspot with any wireless interface recommend external or wifi network interfaces. 