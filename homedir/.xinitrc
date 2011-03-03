#idesk &
$HOME/.monicarc   #monitor calibration
conky &
xset s off
xset -dpms
xset r rate 190 50
setxkbmap it2
numlockx
#xfce4-panel &
tint2 &
#urxvtd -q -f -o

nvidia-settings -l
#nvidia-settings --assign "[gpu:0]/GPUOverclockingState=1" --assign "[gpu:0]/GPU2DClockFreqs=422,680" --assign="[gpu:0]/GPU3DClockFreqs=422,680"
#nvidia-settings --assign "[gpu:0]/GPUOverclockingState=1" --assign "[gpu:0]/GPU2DClockFreqs=400,500" --assign="[gpu:0]/GPU3DClockFreqs=400,500"

#exec startfluxbox
#exec startkde
#exec startxfce4

openbox-session
