#Screen recording script by Damien Sticklen

#!/bin/sh

FILEPREFIX=screencast
EXTENSION=.mkv
NUM=0
FILENAME=$FILEPREFIX$NUM$EXTENSION
EXECPATH=/usr/bin

while [ -f $FILENAME ]; do
	NUM=$((NUM + 1))
	FILENAME=$FILEPREFIX$NUM$EXTENSION
done

if [ -f $EXECPATH/ffmpeg ]; then
	EXEC=$EXECPATH/ffmpeg
elif [ -f $EXECPATH/avconv ]; then
	EXEC=$EXECPATH/avconv
else
	echo "No ffmpeg/avconv found in $EXECPATH. Install ffmpeg/avconv or modify EXECPATH in this script to point to the install path."
	exit 999
fi

PARAMETERS="-video_size 1920x1080 -r 60 -f x11grab -i :0 -f alsa -i hw:0,0 -codec:v libx264 -crf 0 -preset ultrafast -codec:a flac $FILENAME"
	
echo -e $EXEC $PARAMETERS '\n'
$EXEC $PARAMETERS

echo -e "\nFile saved as $PWD/$FILENAME"
