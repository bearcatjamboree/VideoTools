#!/bin/sh
#================================================================================
#  AUTHOR
#    Clint Box
#    https://www.youtube.com/bearcatjamboree
#
#   FUNCTION
#     Jump cut video using audio level
#
#   DETAILS
#     This script will invoke VideoJumpcutter using a specific file and will
#     perform audio jump cut
#
#   USAGE
#     ${SCRIPT_NAME} "video_path"
#================================================================================
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
        set input_file to choose file with prompt "Please choose a file to process"
        POSIX path of input_file
        end')
    elif [[ "$machine" == "Linux" ]]; then
        input_file=$(dialog --title "Choose a file" --stdout --title "Please choose a file to process" --fselect ~/ 14 48)
    elif [[ "$machine" == "Cygwin" ]]; then
        input_file=$(dialog --title "Choose a file" --stdout --title "Please choose a file to process" --fselect ~/ 14 48)
    elif [ "$#" -ne 1 ] || ! [ -f "$input_file" ]; then
        echo "Usage: $0 input_file"
        exit 1
    fi
fi

if ! [ -f "$input_file" ]; then
  echo "Usage: $0 input_file"
  exit 1
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
outfile="$name"_highlights
newoutfile=$outfile.$ext

python VideoJumpcutter.py --input_file "$input_file" --output_file "$newoutfile" --audio_method 1 --volume_selection "rms" --audio_threshold 0.1 --frame_margin 120
#python VideoJumpcutter.py --input_file "$input_file" --output_file "$newoutfile" --audio_method 1 --volume_selection "rms" --audio_threshold 0.2 --frame_margin 60


#python VideoJumpcutter.py --input_file "$input_file" --output_file "$newoutfile" --audio_method 1 --volume_selection "max" --audio_threshold 0.01 --frame_margin 60
#python VideoJumpcutter.py --input_file "$input_file" --output_file "$newoutfile" --audio_method 1 --volume_selection "max" --audio_threshold 0.75 --frame_margin 600
#python VideoJumpcutter.py --input_file "$input_file" --output_file "$newoutfile" --audio_method 1 --volume_selection "rms" --audio_threshold 0.2 --frame_margin 600

#python VideoJumpcutter.py --input_file "$input_file" --output_file "$newoutfile" --audio_method 1 --volume_selection "rms" --audio_threshold 0.40 --frame_margin 150
#python VideoJumpcutter.py --input_file "$input_file" --output_file "$newoutfile" --audio_method 1 --volume_selection "rms" --audio_threshold 0.7 --frame_margin 60