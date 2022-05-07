#!/bin/sh

unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     machine=Linux;;
    Darwin*)    machine=Mac;;
    CYGWIN*)    machine=Cygwin;;
    MINGW*)     machine=MinGw;;
    *)          machine="UNKNOWN:${unameOut}"
esac

echo "${machine}"
input_file="$1"

##############################################################################
# Check for file was passed.  Show open file dialog if no argument and on Mac
###############################################################################
if ! [ -f "$input_file" ]; then
    if [[ "$machine" == "Mac" ]]; then
        input_file=$(osascript -e 'tell application (path to frontmost application as text)
        set input_file to choose file
        POSIX path of input_file
        end')
    elif [[ "$machine" == "Linux" ]]; then
        input_file=$(dialog --title "Choose a file" --stdout --title "Please choose a file to process" --fselect /tmp/ 14 48)
    elif [[ "$machine" == "Cygwin" ]]; then
        input_file=$(dialog --title "Choose a file" --stdout --title "Please choose a file to process" --fselect /tmp/ 14 48)
    elif [ "$#" -ne 1 ] || ! [ -f "$input_file" ]; then
        echo "Usage: $0 input_file"
        exit 1
    fi
fi

####################################
# Remove backlashes from filepaths
####################################
file=$(echo "$input_file"|tr -d '\\')

####################################
# Separate file name from extension
####################################
ext="${file##*.}"
name="${file%.*}"

############################
# Get file path information
############################
outfile="$name"_vintage
newoutfile=$outfile.$ext

####################################
# Empty temp directory
####################################
if ! [ -d "./temp" ]; then
  mkdir temp
else
  rm -Rf temp/*
fi

ffmpeg -i "$input_file" -filter:v fps=fps=10 "temp/step1.$ext"
ffmpeg -i "temp/step1.$ext" -vf curves=vintage,format=yuv420p "temp/step2.$ext"

# Get base video width for adjusting overlay to exact size
width=$(ffprobe -v error -select_streams v -show_entries stream=width -of csv=p=0:s=x "temp/step2.$ext")

ffmpeg -i "media/overlay.mp4" -vf scale=$width:-1,setsar=1:1 "temp/overlay.$ext"
ffmpeg -i "temp/step2.$ext" -i "temp/overlay.$ext" -filter_complex '[1:v]colorkey=0x000000:0.3:0.2[ckout];[0:v][ckout]overlay[out]' -map '[out]' -map 0:a -c:a copy "$newoutfile"

rm -Rf temp
