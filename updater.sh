#!/bin/bash

EXEPREFIX="$WINEPREFIX/drive_c/Program Files/Warframe/Downloaded/Public"

WINECMD=${WINE-wine}

#keep wget as a backup in case curl fails
#wget -qN http://origin.warframe.com/index.txt.lzma
curl -s http://origin.warframe.com/index.txt.lzma -o "$WINEPREFIX/drive_c/Program Files/Warframe/index.txt.lzma"
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

while read -r line; do

    #get the md5 sum from the current line
    MD5SUM=${line: -37:-5}
    #convert it to lower case
    MD5SUM=${MD5SUM,,}

    #check if md5sums.txt exists
    if [ -f "md5sums.txt" ]; then
        #if md5sums.txt exists, check if new md5sum is in it
        if grep -q "$MD5SUM" "md5sums.txt"; then

            #if it's in the list, check if the file exists already
            if [ ! -f "$EXEPREFIX${line:0:-38}" ]; then

                # if file doesnt exist, download it
                #keep wget as a backup in case curl fails
                #wget -x -O "$EXEPREFIX$line" http://content.warframe.com$line
                curl -s http://content.warframe.com$line --create-dirs -o "$EXEPREFIX$line"
                find "$EXEPREFIX" -name '*.lzma' -exec unlzma -f {} \;
                mv "$EXEPREFIX${line:0:-5}" "$EXEPREFIX${line:0:-38}"

            fi
        else
            #if new md5sum isn't in md5sum list,check if the file exists
            if [ -f "$EXEPREFIX${line:0:-38}" ]; then
                #if the file already exists, get its current md5 sum
                OLDMD5SUM=$(md5sum "$EXEPREFIX${line:0:-38}" | awk '{print $1}')

                #then remove it from the md5sum list
                sed -i "/$OLDMD5SUM/,+1 d" md5sums.txt

                #also remove blank lines
                sed -i '/^\s*$/d' md5sums.txt
            fi

            #then download new file
            #keep wget as a backup in case curl fails
            #wget -x -q -O "$EXEPREFIX$line" http://content.warframe.com$line
            curl -s http://content.warframe.com$line --create-dirs -o "$EXEPREFIX$line"
            find "$EXEPREFIX" -name '*.lzma' -exec unlzma -f {} \;
            mv "$EXEPREFIX${line:0:-5}" "$EXEPREFIX${line:0:-38}"

            #and add new md5sum to md5sums.txt
            echo "$MD5SUM" >> "md5sums.txt"
        fi
    else

        #if no md5sum list exists, download all files and log md5sums
        #keep wget as a backup in case curl fails
        #wget -x -q -O "$EXEPREFIX$line" http://content.warframe.com$line
        curl -s http://content.warframe.com$line --create-dirs -o "$EXEPREFIX$line"
        find "$EXEPREFIX" -name '*.lzma' -exec unlzma -f {} \;
        mv "$EXEPREFIX${line:0:-5}" "$EXEPREFIX${line:0:-38}"
        echo "$MD5SUM" >> "md5sums.txt"

    fi

    #show progress percentage
    (( LINECOUNT+=1 ))
    if (( LINECOUNT > PROGRESS )) && (( PERCENT < 101 )); then
        (( PERCENT+=1 ))
        echo -ne "$PERCENT% Downloading $EXEPREFIX${line:0:-38}                                   " "\r";
        LINECOUNT=0
    fi
done < index.txt

# cleanup
rm index.*

if [ "$WINEARCH" = "win64" ]; then
    $WINECMD "$EXEPREFIX/Warframe.x64.exe" -silent -log:/Preprocessing.log -dx10:1 -dx11:1 -threadedworker:1 -cluster:public -language:en -applet:/EE/Types/Framework/ContentUpdate

    echo "*********************"
    echo "Launching Warframe."
    echo "*********************"

    $WINECMD "$EXEPREFIX/Warframe.x64.exe" -log:/Preprocessing.log -dx10:1 -dx11:1 -threadedworker:1 -cluster:public -language:en -fullscreen:0
else
    $WINECMD "$EXEPREFIX/Warframe.exe" -silent -log:/Preprocessing.log -dx10:1 -dx11:1 -threadedworker:1 -cluster:public -language:en -applet:/EE/Types/Framework/ContentUpdate

    echo "*********************"
    echo "Launching Warframe."
    echo "*********************"

    $WINECMD "$EXEPREFIX/Warframe.exe" -log:/Preprocessing.log -dx10:1 -dx11:1 -threadedworker:1 -cluster:public -language:en -fullscreen:0
fi
