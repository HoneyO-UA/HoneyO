if [ "$#" -ne 1 ]; then
    echo "./download_images.sh <output directory> <images URL>"
fi

C=$(pwd)
OUT=$1
URL=$2

cd $OUT
wget $2 # https://github.com/HoneyO-UA/HoneyO/releases/download/v1.0.0/images.zip
7z x images.zip

cd $C
