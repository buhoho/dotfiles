#!/bin/bash
# convert_to_mp3.sh

mkdir mp3 orig

for file in *.{wav,m4a}; do
    [ -f "$file" ] || continue
    basename="${file%.*}"
    echo "🎵 変換中: $file"
    ffmpeg -i "$file" -codec:a libmp3lame -b:a 64k ./mp3/"${basename}.mp3"
    mv "$file" orig
done
