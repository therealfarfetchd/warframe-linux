#!/bin/bash

EXEPREFIX="$WINEPREFIX/drive_c/Program Files/Warframe/Downloaded/Public"

wget -qN http://content.warframe.com/index.txt.lzma
unlzma -f index.txt.lzma

sed -i.bak 's/\.lzma.*/.lzma/' index.txt

while read line
do
    #FIXME:commented out for now. we will check md5sums eventually
    #find "$EXEPREFIX" -name '*.*' -type f -exec md5sum {} \; | awk '{print $1}'

    curl http://content.warframe.com$line --create-dirs -o "$EXEPREFIX$line"
    find "$EXEPREFIX" -name '*.lzma' -exec unlzma -f {} \;
    mv "$EXEPREFIX${line::-5}" "$EXEPREFIX${line::-38}"
done < index.txt

if [ "$WINEARCH" = "win64" ]; then
    wine "$EXEPREFIX/Warframe.x64.exe" -silent -log:/Preprocessing.log -dx10:1 -dx11:1 -threadedworker:1 -cluster:public -language:en -applet:/EE/Types/Framework/ContentUpdate
    wine "$EXEPREFIX/Warframe.x64.exe" -log:/Preprocessing.log -dx10:1 -dx11:1 -threadedworker:1 -cluster:public -language:en -fullscreen:0
else
    wine "$EXEPREFIX/Warframe.exe" -silent -log:/Preprocessing.log -dx10:1 -dx11:1 -threadedworker:1 -cluster:public -language:en -applet:/EE/Types/Framework/ContentUpdate
    wine "$EXEPREFIX/Warframe.exe" -log:/Preprocessing.log -dx10:1 -dx11:1 -threadedworker:1 -cluster:public -language:en -fullscreen:0
fi
