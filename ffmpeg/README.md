# FFMPEG

## Convert Format

```
ffmpeg -i input.m4a -acodec mp3 -ac 2 -ab 192k output.mp3

for file in *.wma; do ffmpeg -i "${file}" -acodec libmp3lame -ab 192k "${file/.wma/.mp3}"; done
```

## Turn up the file volume

Add 10dB volume to the input.mp3

```
ffmpeg -i input.mp3 -af volume=10dB output.mp3
```
