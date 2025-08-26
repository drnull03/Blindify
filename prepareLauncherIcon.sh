#!/bin/bash

#
SOURCE_IMAGE="assets/icon.png"

#
echo "Creating icons..."
#
mkdir -p res/mipmap-mdpi
mkdir -p res/mipmap-hdpi
mkdir -p res/mipmap-xhdpi
mkdir -p res/mipmap-xxhdpi
mkdir -p res/mipmap-xxxhdpi

# Use ImageMagick's 'convert' command to resize
convert "$SOURCE_IMAGE" -resize 48x48   res/mipmap-mdpi/ic_launcher.png
convert "$SOURCE_IMAGE" -resize 72x72   res/mipmap-hdpi/ic_launcher.png
convert "$SOURCE_IMAGE" -resize 96x96   res/mipmap-xhdpi/ic_launcher.png
convert "$SOURCE_IMAGE" -resize 144x144 res/mipmap-xxhdpi/ic_launcher.png
convert "$SOURCE_IMAGE" -resize 192x192 res/mipmap-xxxhdpi/ic_launcher.png

echo "Done creating legacy icons in the 'res' folder."


