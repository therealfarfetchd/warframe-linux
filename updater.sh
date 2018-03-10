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

#keep wget as a backup in case curl fails
#wget -qN http://origin.warframe.com/index.txt.lzma
curl -s http://origin.warframe.com/index.txt.lzma -o index.txt.lzma
unlzma -f index.txt.lzma


echo "*********************"
echo "Checking for updates."
echo "*********************"

#remove old downloaded archives
find "$EXEPREFIX" -name '*.lzma' -exec rm {} \;

#create list of all files to download
rm -f updates.txt
touch updates.txt
while read -r line; do
	# get the raw filename with md5sum and lzma extension
	RAW_FILENAME=$(echo $line | awk -F, '{print $1}')
	# path to local file currently tested
	LOCAL_PATH="$EXEPREFIX${RAW_FILENAME:0:-38}"

	#check if local_index.txt exists
	if [ -f "local_index.txt" ]; then
		#if local index exists, check if new entry is in it
		if grep -q "$RAW_FILENAME" "local_index.txt"; then
			#if it's in the list, check if the file exists already
			if [ ! -f "$LOCAL_PATH" ]; then
				# if file doesnt exist, add it to download list
				echo "$line" >> updates.txt
			fi
		else
			#if new md5sum isn't in local index list, add it to download list
			echo "$line" >> updates.txt
		fi
	else
		#if no md5sum list exists, download all files and log md5sums
		echo "$line" >> updates.txt
	fi
done < index.txt

# sum up total size of updates
TOTAL_SIZE=0
while read -r line; do
	# get the remote size of the lzma file when downloading
	REMOTE_SIZE=$(echo $line | awk -F, '{print $2}' | sed 's/\r//')
	echo "'$REMOTE_SIZE'"
	(( TOTAL_SIZE+=$REMOTE_SIZE ))
done < updates.txt

echo "*********************"
echo "Downloading updates."
echo "*********************"

#currently downloaded size
CURRENT_SIZE=0
PERCENT=0
while read -r line; do
	#get the raw filename with md5sum and lzma extension
	RAW_FILENAME=$(echo $line | awk -F, '{print $1}')
	#get the remote size of the lzma file when downloading
	REMOTE_SIZE=$(echo $line | awk -F, '{print $2}' | sed 's/\r//')
	#get the md5 sum from the current line
	MD5SUM=${RAW_FILENAME: -37:-5}
	#convert it to lower case
	MD5SUM=${MD5SUM,,}
	#path to local file currently tested
	LOCAL_FILENAME="${RAW_FILENAME:0:-38}"
	LOCAL_PATH="$EXEPREFIX${LOCAL_FILENAME}"
	#URL where to download the latest file
	DOWNLOAD_URL="http://content.warframe.com$RAW_FILENAME"
	#path to local file to be downloaded
	LZMA_PATH="$EXEPREFIX${RAW_FILENAME}"
	#path to downloaded and extracted file
	EXTRACTED_PATH="$EXEPREFIX${RAW_FILENAME:0:-5}"

	#variable to specify whether to download current file or not
	do_update=true

	if [ -f "$LOCAL_PATH" ]; then
		#local file exists

		#check md5sum of local file
		OLDMD5SUM=$(md5sum "$LOCAL_PATH" | awk '{print $1}')

		if [ "$OLDMD5SUM" = "$MD5SUM" ]; then
			#nothing to do
			do_update=false
		else
			#md5sum mismatch, download new file
			do_update=true
		fi
	else
		# local file does not exist
		do_update=true
	fi

	if [ -f local_index.txt ]; then
		#remove old local_index entry
		sed -i "\#${LOCAL_FILENAME}.*#,+1 d" local_index.txt

		#also remove blank lines
		sed -i '/^\s*$/d' local_index.txt
	fi

	#do download
	if [ "$do_update" = true ]; then
		#show progress percentage for each downloading file
		echo -ne "$PERCENT% ($CURRENT_SIZE/$TOTAL_SIZE) Downloading ${REMOTE_SIZE} ${RAW_FILENAME}                                   " "\r";

		#download file and replace old file
		#keep wget as a backup in case curl fails
		#wget -x -O "$EXEPREFIX$line" http://content.warframe.com$line
		curl -s $DOWNLOAD_URL --create-dirs -o "$LZMA_PATH"
		unlzma -f "$LZMA_PATH"
		mv "$EXTRACTED_PATH" "$LOCAL_PATH"
	fi

	#update local index
	echo "$line" | sed 's/\r//' >> local_index.txt

	#update progress percentage
	(( CURRENT_SIZE+=$REMOTE_SIZE ))
	PERCENT=$(( ${CURRENT_SIZE}*100/${TOTAL_SIZE} ))
done < updates.txt
#print finished message
echo "$PERCENT% ($CURRENT_SIZE/$TOTAL_SIZE) Finished downloads"

# cleanup
rm updates.txt
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
