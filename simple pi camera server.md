# simple pi camera server
Yes, you can definitely do real-time streaming with the Pi Camera on DietPi CLI! Here are several options:

## 1. **Real-Time MJPEG Stream (Simplest)**

Create a simple HTTP stream viewable in any browser:

```bash
# Install required package
sudo apt install -y libcamera-apps

# Start streaming on port 8080
libcamera-vid -t 0 --inline --listen -o tcp://0.0.0.0:8080
```

View at: `http://[your-pi-ip]:8080/` in VLC or browser

## 2. **Python Real-Time Stream with Flask**

Create `stream_server.py`:

```python
#!/usr/bin/env python3
from flask import Flask, Response
from picamera2 import Picamera2
import io
import time

app = Flask(__name__)
picam2 = Picamera2()

def generate_frames():
    picam2.configure(picam2.create_video_configuration(main={"size": (640, 480)}))
    picam2.start()
    
    while True:
        stream = io.BytesIO()
        picam2.capture_file(stream, format='jpeg')
        stream.seek(0)
        yield (b'--frame\r\n'
               b'Content-Type: image/jpeg\r\n\r\n' + stream.read() + b'\r\n')
        time.sleep(0.033)  # ~30fps

@app.route('/')
def index():
    return '''<html><body>
    <h1>Pi Camera Live Stream</h1>
    <img src="/video_feed" width="640" height="480">
    </body></html>'''

@app.route('/video_feed')
def video_feed():
    return Response(generate_frames(),
                    mimetype='multipart/x-mixed-replace; boundary=frame')

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, threaded=True)
```

Install Flask and run:
```bash
pip3 install flask
python3 stream_server.py
```

## 3. **RTSP Stream (Professional)**

For VLC, security cameras, or other RTSP clients:

```bash
# Using libcamera with cvlc
libcamera-vid -t 0 --inline --listen -o - | \
cvlc stream:///dev/stdin --sout '#rtp{sdp=rtsp://:8554/stream}' :demux=h264
```

View in VLC: `rtsp://[your-pi-ip]:8554/stream`

## 4. **Direct Network Stream (Low Latency)**

For minimal latency over network:

```bash
# On Pi (sender):
libcamera-vid -t 0 --codec h264 --inline --listen -o tcp://0.0.0.0:5000

# On receiving computer:
ffplay tcp://[your-pi-ip]:5000 -fflags nobuffer -flags low_delay -framedrop
```

## 5. **Terminal Preview (ASCII)**

For viewing directly in terminal:

```bash
# Install dependencies
sudo apt install -y libcamera-apps fbcat imagemagick

# Create preview script
cat > preview.sh << 'EOF'
#!/bin/bash
while true; do
    libcamera-still -o - -t 1 --width 80 --height 40 -n | \
    convert - -resize 80x40 txt:- | \
    awk -F'[,:]' 'NR>1{print $3}' | \
    sed 's/[0-9]*//g;s/srgb//g;s/[()]//g' | \
    awk '{printf "%s", ($1+$2+$3)/3 < 128 ? "#" : " "} NR%80==0{print ""}'
    clear
done
EOF

chmod +x preview.sh
./preview.sh
```

## 6. **Motion Detection Stream**

Real-time with motion detection:

```python
#!/usr/bin/env python3
import cv2
import numpy as np
from picamera2 import Picamera2
import time

picam2 = Picamera2()
config = picam2.create_video_configuration(main={"size": (640, 480)})
picam2.configure(config)
picam2.start()

prev_frame = None
motion_threshold = 30

print("Motion detection started. Press Ctrl+C to stop.")

try:
    while True:
        frame = picam2.capture_array()
        gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
        
        if prev_frame is not None:
            diff = cv2.absdiff(prev_frame, gray)
            _, thresh = cv2.threshold(diff, motion_threshold, 255, cv2.THRESH_BINARY)
            motion_pixels = cv2.countNonZero(thresh)
            
            if motion_pixels > 1000:  # Adjust sensitivity
                timestamp = time.strftime("%Y-%m-%d %H:%M:%S")
                print(f"[{timestamp}] Motion detected! Pixels: {motion_pixels}")
                # Optional: Save image
                # cv2.imwrite(f"motion_{int(time.time())}.jpg", frame)
        
        prev_frame = gray
        time.sleep(0.1)
        
except KeyboardInterrupt:
    print("\nStopping...")
finally:
    picam2.stop()
```
 
