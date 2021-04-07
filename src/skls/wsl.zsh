export DISPLAY=$(ip route | awk '{print $3; exit}'):0
export LIBGL_ALWAYS_INDIRECT=1
export GDK_SCALE=1
setxkbmap us -variant intl
