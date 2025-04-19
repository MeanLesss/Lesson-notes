#!/usr/bin/env python3
# wifi_setup.py

import time
import subprocess
import os
import sys
import RPi.GPIO as GPIO
from st7789 import ST7789

# Required tools and driver repo
required_tools = ["bully", "hashcat", "hcxdumptool", "hcxtools", "macchanger"]
conflicting_processes = ["avahi-daemon", "NetworkManager", "wpa_supplicant"]
driver_repo_url = "https://github.com/aircrack-ng/rtl8812au.git"

# GPIO button pins
BTN_LEFT = 17
BTN_RIGHT = 27
BTN_SELECT = 22

# Initialize GPIO
GPIO.setmode(GPIO.BCM)
GPIO.setup(BTN_LEFT, GPIO.IN, pull_up_down=GPIO.PUD_UP)
GPIO.setup(BTN_RIGHT, GPIO.IN, pull_up_down=GPIO.PUD_UP)
GPIO.setup(BTN_SELECT, GPIO.IN, pull_up_down=GPIO.PUD_UP)

# Initialize ST7789
disp = ST7789(ST7789.MAIN, rotation=0)

def display_message(text, lines=3):
    disp.clear()
    for i in range(lines):
        disp.text(text[i*20:(i+1)*20], 0, i*10)
    disp.show()

def wait_for_press(pin):
    while GPIO.input(pin) == GPIO.HIGH:
        time.sleep(0.05)
    time.sleep(0.2)

def install_tools():
    display_message("Installing tools...")
    for tool in required_tools:
        result = subprocess.run(["which", tool], stdout=subprocess.PIPE)
        if not result.stdout:
            display_message(f"Installing {tool}...")
            subprocess.run(["sudo", "apt", "install", "-y", tool])

def install_driver():
    repo_dir = os.path.expanduser("~/rtl8812au")
    if not os.path.exists(repo_dir):
        subprocess.run(["git", "clone", driver_repo_url])
    subprocess.run(["sudo", "apt", "install", "-y", "dkms", "raspberrypi-kernel-headers", "build-essential", "bc"])
    subprocess.run(["sudo", "make", "dkms_install"], cwd=repo_dir)

def kill_conflicts():
    display_message("Killing processes...")
    for proc in conflicting_processes:
        try:
            pids = subprocess.check_output(["pidof", proc]).decode().split()
            for pid in pids:
                subprocess.run(["sudo", "kill", "-9", pid])
        except:
            pass

def run_wifite():
    display_message("Launching Wifite...")
    subprocess.run(["sudo", "wifite", "--kill"])

def main_menu():
    options = ["Driver & Kill", "Install Tools", "Run Wifite"]
    selected = 0

    while True:
        display_message(f"> {options[selected]}")
        if GPIO.input(BTN_LEFT) == GPIO.LOW:
            wait_for_press(BTN_LEFT)
            selected = (selected - 1) % len(options)
        if GPIO.input(BTN_RIGHT) == GPIO.LOW:
            wait_for_press(BTN_RIGHT)
            selected = (selected + 1) % len(options)
        if GPIO.input(BTN_SELECT) == GPIO.LOW:
            wait_for_press(BTN_SELECT)
            if selected == 0:
                install_driver()
                kill_conflicts()
            elif selected == 1:
                install_tools()
            elif selected == 2:
                run_wifite()

if __name__ == "__main__":
    try:
        main_menu()
    finally:
        GPIO.cleanup()
