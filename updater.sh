#!/bin/bash

EXEPREFIX="$WINEPREFIX/drive_c/Program Files/Warframe/Downloaded/Public"
##TODO use curl instead of wget
wget -qN http://content.warframe.com/index.txt.lzma
unlzma -f index.txt.lzma

echo "*********************"
echo "Checking for updates."
echo "*********************"

find "$EXEPREFIX" -name '*.lzma' -exec rm {} \;

sed -i.bak 's/\.lzma.*/.lzma/' index.txt
if [ -d "$EXEPREFIX" ] && [ ! -f "md5sums.txt" ]; then
    find "$EXEPREFIX" -name '*.*' -type f -exec md5sum {} \; | awk '{print $1}' > md5sums.txt;
fi

echo "*********************"
echo "Downloading updates."
echo "*********************"

PROGRESS=$(wc -l index.txt)
PROGRESS=$((${PROGRESS::-10}/100))
LINECOUNT=0
PERCENT=0

while read line
do
    MD5SUM=${line: -32:-5}
    MD5SUM=${MD5SUM,,}
    if [ -f "md5sums.txt" ] && grep -q $MD5SUM "md5sums.txt"; then
        :
    else
        curl -s http://content.warframe.com$line --create-dirs -o "$EXEPREFIX$line"
        find "$EXEPREFIX" -name '*.lzma' -exec unlzma -f {} \;
        mv "$EXEPREFIX${line::-5}" "$EXEPREFIX${line::-38}"
    fi
    (( LINECOUNT+=1 ))
    if (( LINECOUNT > PROGRESS )) && (( PERCENT < 101 )); then
        (( PERCENT+=1 ))
        ##TODO: Add a progress bar
        echo -ne "$PERCENT%"'\r';
        LINECOUNT=0
    fi
done < index.txt

cp updater.sh "$WINEPREFIX/drive_c/Program Files/Warframe/updater.exe"

if [ "$WINEARCH" = "win64" ]; then
    wine "$EXEPREFIX/Warframe.x64.exe" -silent -log:/Preprocessing.log -dx10:1 -dx11:1 -threadedworker:1 -cluster:public -language:en -applet:/EE/Types/Framework/ContentUpdate

    echo "*********************"
    echo "Launching Warframe."
    echo "*********************"

    wine "$EXEPREFIX/Warframe.x64.exe" -log:/Preprocessing.log -dx10:1 -dx11:1 -threadedworker:1 -cluster:public -language:en -fullscreen:0
else
    wine "$EXEPREFIX/Warframe.exe" -silent -log:/Preprocessing.log -dx10:1 -dx11:1 -threadedworker:1 -cluster:public -language:en -applet:/EE/Types/Framework/ContentUpdate

    echo "*********************"
    echo "Launching Warframe."
    echo "*********************"

    wine "$EXEPREFIX/Warframe.exe" -log:/Preprocessing.log -dx10:1 -dx11:1 -threadedworker:1 -cluster:public -language:en -fullscreen:0
fi
