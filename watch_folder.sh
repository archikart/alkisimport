#!/bin/bash

file_to_wait="$1"
directory="$(dirname $file_to_wait)"
filename="$(basename $file_to_wait)"

inotifywait -mq -e create -e modify --format %f "$directory" | 
while read line
do
	if [ "$line" = "$filename" ] ; then
		pid=$(pgrep inotify -a | grep "$directory")
		pid=${pid%% *}
		kill $pid
	else
		echo "$line / $(cat "$directory/$line")"
	fi
done
