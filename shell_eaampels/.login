# (The .login File)
stty -istrip
stty erase ^h	
stty kill ^u
#
# If possible start the windows system. 
# Give a user a chance to bail out
#
if ( $TERM == "linux" ) then
            echo "Starting X windows.  Press control C \
                  to exit within the next 5 seconds "
            sleep 5
            startx
endif
set autologout=60
