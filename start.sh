#!/bin/bash

# Start Xtiger vnc
Xtigervnc ${DISPLAY} -rfbport ${VNC_PORT} -localhost -SecurityTypes=none -geometry ${VNC_GEOMETRY} &
  
# Start noVNC
/home/developer/noVNC/utils/novnc_proxy --vnc localhost:${VNC_PORT} --listen ${NOVNC_PORT} &

# Start emulator
/home/developer/Android/emulator/emulator @${ANDROID_DEVICENAME} -gpu swiftshader_indirect -accel on -wipe-data -writable-system -verbose &
  
# Wait for any process to exit
wait -n
  
# Exit with status of process that exited first
exit $?