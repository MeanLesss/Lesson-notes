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
"""
Lightweight Pi Camera Web Server for DietPi
Optimized for Pi Zero 2W - No PHP/Apache needed
"""

from http.server import HTTPServer, BaseHTTPRequestHandler
from picamera2 import Picamera2
import io
import time
import threading
import os

class CameraServer(BaseHTTPRequestHandler):
    camera = None
    
    @classmethod
    def initialize_camera(cls):
        if cls.camera is None:
            try:
                cls.camera = Picamera2()
                # Simpler config for better compatibility
                config = cls.camera.create_still_configuration(
                    main={"size": (640, 480)}
                )
                cls.camera.configure(config)
                cls.camera.start()
                time.sleep(2)  # Camera warm-up
                print("Camera initialized successfully")
            except Exception as e:
                print(f"Camera initialization failed: {e}")
                cls.camera = None
                raise
    
    def do_GET(self):
        if self.path == '/':
            # Serve main page
            self.send_response(200)
            self.send_header('Content-type', 'text/html')
            self.end_headers()
            
            html = """
            <!DOCTYPE html>
            <html>
            <head>
                <title>Pi Camera - DietPi</title>
                <meta name="viewport" content="width=device-width, initial-scale=1">
                <style>
                    body { font-family: Arial; text-align: center; background: #f0f0f0; }
                    .container { max-width: 800px; margin: 0 auto; padding: 20px; }
                    img { max-width: 100%; height: auto; border: 2px solid #333; }
                    button { 
                        background: #4CAF50; color: white; padding: 10px 20px; 
                        border: none; cursor: pointer; margin: 5px; font-size: 16px;
                    }
                    button:hover { background: #45a049; }
                    #status { margin: 10px; color: #333; }
                </style>
            </head>
            <body>
                <div class="container">
                    <h1>Pi Camera Stream</h1>
                    <img id="stream" src="/stream.mjpg" alt="Camera Stream" style="width:1920px;height:1080px;">
                    <br><br>
                    <button onclick="capture()">Capture Photo</button>
                    <button onclick="toggleStream()">Toggle Stream</button>
                    <div id="status"></div>
                </div>
                
                <script>
                    let streaming = true;
                    const img = document.getElementById('stream');
                    const status = document.getElementById('status');
                    
                    function toggleStream() {
                        streaming = !streaming;
                        if (streaming) {
                            img.src = '/stream.mjpg?' + Date.now();
                            status.textContent = 'Stream started';
                        } else {
                            img.src = '/snapshot.jpg?' + Date.now();
                            status.textContent = 'Stream paused';
                        }
                    }
                    
                    function capture() {
                        fetch('/capture')
                            .then(response => response.text())
                            .then(data => {
                                status.textContent = data;
                                setTimeout(() => status.textContent = '', 3000);
                            });
                    }
                    
                    // Auto-refresh snapshot if stream fails
                    img.onerror = function() {
                        if (streaming) {
                            setTimeout(() => {
                                img.src = '/snapshot.jpg?' + Date.now();
                            }, 1000);
                        }
                    };
                </script>
            </body>
            </html>
            """
            self.wfile.write(html.encode())
            
        elif self.path == '/snapshot.jpg':
            # Single snapshot
            self.send_response(200)
            self.send_header('Content-type', 'image/jpeg')
            self.end_headers()
            
            stream = io.BytesIO()
            self.initialize_camera()
            self.camera.capture_file(stream, format='jpeg')
            stream.seek(0)
            self.wfile.write(stream.read())
            
        elif self.path.startswith('/stream.mjpg'):
            # MJPEG stream
            self.send_response(200)
            self.send_header('Content-type', 'multipart/x-mixed-replace; boundary=frame')
            self.end_headers()
            
            self.initialize_camera()
            try:
                while True:
                    stream = io.BytesIO()
                    self.camera.capture_file(stream, format='jpeg')
                    stream.seek(0)
                    
                    self.wfile.write(b'--frame\r\n')
                    self.send_header('Content-type', 'image/jpeg')
                    self.send_header('Content-length', str(stream.getbuffer().nbytes))
                    self.end_headers()
                    self.wfile.write(stream.read())
                    
                    time.sleep(0.1)  # 10 FPS for Pi Zero 2W
            except Exception as e:
                print(f"Stream ended: {e}")
                
        elif self.path == '/capture':
            # Capture and save photo
            self.send_response(200)
            self.send_header('Content-type', 'text/plain')
            self.end_headers()
            
            timestamp = time.strftime("%Y%m%d_%H%M%S")
            filename = f"capture_{timestamp}.jpg"
            self.initialize_camera()
            self.camera.capture_file(filename)
            
            response = f"Photo saved as {filename}"
            self.wfile.write(response.encode())
            
        else:
            self.send_error(404)
    
    def log_message(self, format, *args):
        # Reduce console spam
        if '/stream.mjpg' not in args[0]:
            super().log_message(format, *args)

def run_server(port=8090):
    """Start the camera web server"""
    server_address = ('', port)
    httpd = HTTPServer(server_address, CameraServer)
    
    print(f"Camera server running on port {port}")
    print(f"Access at: http://YOUR_PI_IP:{port}/")
    print("Press Ctrl+C to stop")
    
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\nShutting down...")
        if CameraServer.camera:
            CameraServer.camera.stop()
        httpd.shutdown()

if __name__ == '__main__':
    # Create directory for captures
    os.makedirs("captures", exist_ok=True)
    os.chdir("captures")
    
    # Start server
    run_server(8090)
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
 
