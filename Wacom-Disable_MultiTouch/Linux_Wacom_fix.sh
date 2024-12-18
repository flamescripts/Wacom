#!/bin/bash
## 09/03/19
##
## Name: CentOS_Wacom_fix.sh
## Desc: Disable Wacom Multi-Touch, ExpressKeys and Finger Wheel
## with minimal user interaction.  Add pointer from rc.local to persist
## after reboot.  Workaround available by request.
##
## Always Current Version:
##      https://github.com/flamescripts/Flame_Scripts
##
## Disclamer: This is not an official Autodesk certified script.  Neither the
## author nor Autodesk are responsible for any use, misuse, unintened results 
## or data loss that may ocurr from using this script.
##
## Use at your own risk.  Script intended for providing guidance only.
##
## Test Models: Intuos 4, Intuos Pro Medium, Intuos Pro Large, Intuos5 Touch Medium
## PTH-660
##
## Test OS: Autodesk CentOS 7.2, Rocky 9.3
##
## IMPORTANT:  If using script remotely via ssh, be sure to export the DISPLAY
## ex: export DISPLAY=:0
##
## Note: For Rocky 8+ it is recommended to use the Wacom tab in the Device Settings
## in the OS, if available.  A few Gnome instances lacked this option. In these
## instances, this script should be used.  However. if the option is available,
## it is advised to use the built in OS functionality to disable touch and gestures,
##
##########################################################################


# Variables
PAD=`xsetwacom --list devices | awk '/PAD/||/pad/||/Pad/' | awk -F "id:" '{print $1}' | cut -d " " -f1-8  | sed -e 's/[[:space:]]*$//'`
TOUCH=`xsetwacom --list devices | awk '/FINGER/||/finger/||/Finger/||/TOUCH/||/touch/||/Touch/' | awk -F "id:" '{print $1}' | cut -d " " -f1-8  | sed -e 's/[[:space:]]*$//'`
STYLUS=`xsetwacom --list devices | awk '/STYLUS/||/stylus/||/Stylus/' | awk -F "id:" '{print $1}' | cut -d " " -f1-8  | sed -e 's/[[:space:]]*$//'`
CURSOR=`xsetwacom --list devices | awk '/CURSOR/||/cursor/||/Cursor/' | awk -F "id:" '{print $1}' | cut -d " " -f1-8  | sed -e 's/[[:space:]]*$//'`
ERASER=`xsetwacom --list devices | awk '/ERASER/||/eraser/||/Eraser/' | awk -F "id:" '{print $1}' | cut -d " " -f1-8  | sed -e 's/[[:space:]]*$//'`
RING=( AbsWheelUp AbsWheelDown AbsWheel2Up AbsWheel2Down RelWheelUp RelWheelDown StripLeftUp StripLeftDown StripRightUp StripRightDown )

ZERO='button 0'
ZEROALT='0'


# SSH DISPLAY
if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
        clear
        echo "It looks like you are using a remote shell"
        echo "You MUST export display if errors occur: '${bold}export DISPLAY=:0'"
        read -n 1 -s -r -p "Press any key to continue"
fi


# Reset console
clear


# Model IDs for reference
echo 'CentOS Wacom fix script'
echo 'PAD:' $PAD
echo 'STYLUS:' $STYLUS
echo 'ERASER:' $ERASER
echo 'CURSOR:' $CURSOR

# Turn off touch
if [[ $TOUCH ]]; then
        echo 'TOUCH: ' $TOUCH
        echo
        echo '  Touch is currently turned:' `xsetwacom get "$TOUCH" TOUCH`
        echo
        echo 'Turning touch off'
                xsetwacom set "$TOUCH" TOUCH off
else
        echo 'TOUCH:  no touch feature detected on this Wacom tablet'
        echo
fi


# Turn off ring
echo
echo 'Turning ring off'
for r in "${RING[@]}"
do
        xsetwacom set "$PAD" "$r" "$ZERO"
        # Verify changes correct for ring - Comment out to silence
        echo "  *$r:"  `xsetwacom get "$PAD" "$r"`
done

# Turn off expresskeys 1-3, 8-13
echo
echo 'Turning expresskeys off'
for e in {1..3} {8..13}
do
        xsetwacom set "$PAD" Button "$e" "$ZERO"
        #Verify changes correct for buttons  - Comment out to silence
        echo "  *ExpressKey #$e:" `xsetwacom get "$PAD" Button "$e"`
done

echo
echo


## Get user input for more Wacom info or exit
## Comment out if automating

echo -n "Press any key to display extra Wacom data for diagnostics or just press Esc to exit"

while read -r -n 1 response; do

if [[ $response = $'\e' ]]; then
        echo
        echo 'Script Complete'
        break;
else
        echo
        xsetwacom -s get "$PAD" all
        xsetwacom -s get "$TOUCH" all
        xsetwacom -s get "$STYLUS" all
        xsetwacom -s get "$ERASER" all
        xsetwacom -s get "$CURSOR" all
        libwacom-list-local-devices
        xinput list "$PAD"
        rpm -qa |grep -i wacom
        echo
        echo 'Script Complete'
        break;
fi
done

# Goodbye

exit
