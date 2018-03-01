#!/bin/bash

EXEPREFIX="$WINEPREFIX/drive_c/Program Files/Warframe/Downloaded/Public"

wget -qN http://content.warframe.com/index.txt.lzma
unlzma -f index.txt.lzma

sed -i.bak 's/\.lzma.*/.lzma/' index.txt

wget -qN http://content.warframe.com$(grep index.txt -e Warframe.exe.*)
wget -qN http://content.warframe.com$(grep index.txt -e Warframe.x64.exe.*)
unlzma -f Warframe.exe.*.lzma
unlzma -f Warframe.x64.exe.*.lzma
if [ ! -d "$EXEPREFIX" ];then
    mkdir --parents "$EXEPREFIX"
fi
mv Warframe.x64.exe.* "$EXEPREFIX/Warframe.x64.exe"
mv Warframe.exe.* "$EXEPREFIX/Warframe.exe"

if [ "$WINEARCH" = "win64" ]; then
    wine "$EXEPREFIX/Warframe.x64.exe" -silent -log:/Preprocessing.log -dx10:1 -dx11:1 -threadedworker:1 -cluster:public -language:en -applet:/EE/Types/Framework/ContentUpdate
    wine "$EXEPREFIX/Warframe.x64.exe" -log:/Preprocessing.log -dx10:1 -dx11:1 -threadedworker:1 -cluster:public -language:en -fullscreen:0
else
    wine "$EXEPREFIX/Warframe.exe" -silent -log:/Preprocessing.log -dx10:1 -dx11:1 -threadedworker:1 -cluster:public -language:en -applet:/EE/Types/Framework/ContentUpdate
    wine "$EXEPREFIX/Warframe.exe" -log:/Preprocessing.log -dx10:1 -dx11:1 -threadedworker:1 -cluster:public -language:en -fullscreen:0
fi
wine Downloaded/Public/
