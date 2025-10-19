#!/bin/bash

# Cleanup function to kill all background processes
cleanup() {
    echo "Stopping container, cleaning up..."
    # Kill all child processes gracefully
    kill -TERM $XVFB_PID $FLUXBOX_PID $VNC_PID $WEBSOCK_PID $RVIZ_PID 2>/dev/null
    rm -f /tmp/.X1-lock /tmp/.X11-unix/X1
    exit 0
}

# Trap SIGTERM (sent by "docker stop") and SIGINT (sent by Ctrl+C)
trap cleanup SIGTERM SIGINT

# Remove old locks just in case
rm -f /tmp/.X1-lock /tmp/.X11-unix/X1

# Start services and store their PIDs
echo "Starting Xvfb..."
Xvfb :1 -screen 0 1920x1080x24 > /dev/null 2>&1 &
XVFB_PID=$!
sleep 4

export DISPLAY=:1
echo "Starting fluxbox..."
fluxbox > /dev/null 2>&1 &
FLUXBOX_PID=$!
sleep 1

echo "Starting x11vnc..."
x11vnc -forever -usepw -display :1 -rfbport 5900 -shared -quiet > /dev/null 2>&1 &
VNC_PID=$!
sleep 1

echo "Starting websockify..."
websockify --web=/usr/share/novnc 6080 localhost:5900 > /dev/null 2>&1 &
WEBSOCK_PID=$!
sleep 1

# Source ROS
export ROS_LOCALHOST_ONLY=1
export ROS_DOMAIN_ID=0
source /opt/ros/jazzy/setup.bash
if [ -f /workspace/install/setup.bash ]; then source /workspace/install/setup.bash; fi

# Start the main application (rviz2) in the background
echo "Starting rviz2..."
rviz2 2>&1 | grep -v "^\\[WARN\\]" | grep -v "QStandardPaths" &
RVIZ_PID=$!

# Wait for any of the critical processes to exit.
# This will wait for the first one (Xvfb or rviz2) to die.
wait -n $XVFB_PID $RVIZ_PID

# If we reach here, one of the main processes died, so trigger cleanup
echo "A critical process died, cleaning up..."
cleanup