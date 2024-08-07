#!/usr/bin/env bash

set -e

if [ $# -eq 0 ]; then
	osascript -e 'display notification "No video file provided" with title "Convert to HEVC"'
	exit 1
fi

infile="${1}"
original_profile=$(ffprobe -v error -select_streams v:0 -show_entries stream=profile -of default=noprint_wrappers=1:nokey=1 "$infile")
original_codec=$(ffprobe -v error -select_streams v:0 -show_entries stream=codec_name -of default=noprint_wrappers=1:nokey=1 "$infile")
original_comment=$(exiftool -Comment -s3 "$infile")
if [ "$original_comment" == *"BetterThanHEVC"* ]; then
	osascript -e 'display notification "Already better than HEVC. Nothing to do." with title "HEVC converter"'
	exit 1
fi
if [ "$original_codec" == "hevc" ] && [ $original_profile == "Main" ]; then
	osascript -e 'display notification "Already in HEVC. Nothing to do." with title "HEVC converter"'
	exit 1
fi
infile_base=$(basename "$infile")
infile_dir=$(dirname "$infile")
outfile="${infile_dir}/(HEVC)${infile_base}"

ffmpeg -hide_banner -loglevel error -i "${1}" -c:v hevc_videotoolbox -q:v 52 -tag:v hvc1 -profile:v main "${outfile}"

infile_size=$(wc -c $infile | cut -d' ' -f2)
outfile_size=$(wc -c $outfile | cut -d' ' -f2)
ratio=$(echo "$outfile_size*100 / $infile_size" | bc)
isSmaller=$(echo "$ratio < 100" | bc)
if [ "$isSmaller" -eq 1 ] || [ "$original_profile" != "Main" ]; then
	trash "${infile}"
	mv "${outfile}" "${infile}"
	osascript -e 'display notification "Trash original file." with title "HEVC converter"'
else
	trash "${outfile}"
	exiftool -Comment="${original_comment}BetterThanHEVC" $infile
	osascript -e 'display notification "Trash HEVC file." with title "HEVC converter"'
fi
