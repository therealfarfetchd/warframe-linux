#!/bin/bash

# Change to your preferred installation directory
GAMEDIR="/home/${USER}/Games/Warframe"
USE_DXVK=0

SHARE="$HOME/.local/share"

echo "*************************************************"
echo "Creating wine prefix and performing winetricks."
echo "*************************************************"

WINEDEBUG=-all WINEARCH=win64 WINEPREFIX=$GAMEDIR winetricks -q vcrun2015 xact xinput win7

echo "*************************************************"
echo "Creating warframe directories."
echo "*************************************************"
mkdir -p ${GAMEDIR}/drive_c/Program\ Files/Warframe/
mkdir -p ${GAMEDIR}/drive_c/users/${USER}/Local\ Settings/Application\ Data/Warframe

echo "*************************************************"
echo "Copying warframe files."
echo "*************************************************"
cp -R * ${GAMEDIR}/drive_c/Program\ Files/Warframe/ 

cd ${GAMEDIR}/drive_c/Program\ Files/Warframe/
chmod a+x updater.exe
chmod a+x updater.sh
mv EE.cfg ${GAMEDIR}/drive_c/users/${USER}/Local\ Settings/Application\ Data/Warframe/EE.cfg

echo "*************************************************"
echo "Applying warframe wine prefix registry settings."
echo "*************************************************"
sed "s/%USERNAME%/"$USER"/g" wf.reg > wf_patched.reg
WINEDEBUG=-all WINEARCH=win64 WINEPREFIX=$GAMEDIR wine regedit /S wf_patched.reg
rm wf_patched.reg


echo "*************************************************"
echo "The next few steps will prompt you for shortcut creations."
echo "*************************************************"

echo "*************************************************"
echo "Creating warframe shell script"
echo "*************************************************"

echo "#!/bin/bash" > warframe.sh

echo "export PULSE_LATENCY_MSEC=60" >> warframe.sh
echo "export __GL_THREADED_OPTIMIZATIONS=1" >> warframe.sh
echo "export MESA_GLTHREAD=TRUE" >> warframe.sh


echo "cd ${GAMEDIR}/drive_c/Program\ Files/Warframe/" >> warframe.sh
echo "WINEARCH=win64 WINEPREFIX=$GAMEDIR WINEDEBUG=-all bash updater.sh" >> warframe.sh


chmod a+x warframe.sh
cp ${GAMEDIR}/drive_c/Program\ Files/Warframe/warframe.sh "$HOME/bin/warframe"

read -p "Would you like a menu shortcut? y/n " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
	echo "*************************************************"
	echo "Creating warframe application menu shortcut."
	echo "*************************************************"

  mkdir -p "$SHARE/pixmaps/"
  mkdir -p "$SHARE/applications/"

	cp warframe.png "$SHARE/pixmaps/"

	echo "[Desktop Entry]" > warframe.desktop
	echo "Encoding=UTF-8" >> warframe.desktop
	echo "Name=Warframe" >> warframe.desktop
	echo "GenericName=Warframe" >> warframe.desktop
	echo "Warframe" >> warframe.desktop
	echo "Exec=$HOME/bin/warframe \"\$@\"" >> warframe.desktop
	echo "Icon=$SHARE/pixmaps/warframe.png" >> warframe.desktop
	echo "StartupNotify=true" >> warframe.desktop
	echo "Terminal=false" >> warframe.desktop
	echo "Type=Application" >> warframe.desktop
	echo "Categories=Application;Game" >> warframe.desktop

	cp warframe.desktop "$SHARE/applications/"

  read -p "Would you like a desktop shortcut? y/n " -n 1 -r
  echo    # (optional) move to a new line
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
  	echo "*************************************************"
  	echo "Creating warframe desktop shortcut."
  	echo "*************************************************"
  	cp "$SHARE/applications/warframe.desktop" "$HOME/Desktop/"
  fi
fi


echo "*************************************************"
echo "Installation complete! It is safe to delete this folder."
echo "*************************************************"
