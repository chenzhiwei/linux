# FFMPEG

## Convert Format

```
ffmpeg -i input.m4a -acodec mp3 -ac 2 -ab 192k output.mp3
```

## Turn up the file volume

Add 10dB volume to the input.mp3

```
ffmpeg -i input.mp3 -af volume=10dB output.mp3
```
