#!/usr/bin/env bash

set -e

if [ $# -eq 0 ]; then
    osascript -e 'display notification "No video file provided" with title "Convert to HEVC"'
    exit 1
fi

infile="${1}"
infile_bname=$(basename "$infile")
infile_dname=$(dirname "$infile")
outfile="${infile_dname}/(HEVC)${infile_bname}"

ffmpeg -hide_banner -loglevel error -i "${1}" -c:v hevc_videotoolbox -q:v 52 -tag:v hvc1 "${outfile}"

infile_size=`wc -c $infile | cut -d' ' -f2`
outfile_size=`wc -c $outfile | cut -d' ' -f2`
ratio=$(echo "$outfile_size*100 / $infile_size" | bc)
isSmaller=$(echo "$ratio < 100" | bc)
if [ $isSmaller -eq 1 ]
then
    trash "${infile}"
    osascript -e 'display notification "Trash original file." with title "Convert to HEVC"'
else
    trash "${outfile}"
    osascript -e 'display notification "Trash HEVC file." with title "Convert to HEVC"'
    mv "$infile" "${infile_dname}/(OPT)${infile_bname}"
fi
