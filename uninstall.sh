#!/bin/bash

# Change to your preferred installation directory
GAMEDIR="${HOME}/Games/Warframe"

echo "*************************************************"
echo "The next few steps will remove all shortcuts and warframe files."
echo "*************************************************"

echo "*************************************************"
echo "Removing /usr/bin/warframe"
echo "*************************************************"
rm -R "${HOME}/bin/warframe"

echo "*************************************************"
echo "Removing /usr/share/pixmaps/warframe.png"
echo "*************************************************"
rm -R "${HOME}/.local/share/pixmaps/warframe.png"

echo "*************************************************"
echo "Removing /usr/share/applications/warframe.desktop"
echo "*************************************************"
rm -R "${HOME}/.local/share/applications/warframe.desktop"

echo "*************************************************"
echo "Removing sudo rm -R ${HOME}/Desktop/warframe.desktop"
echo "*************************************************"
rm -R "${HOME}/Desktop/warframe.desktop"

echo "*************************************************"
echo "Removing ${HOME}/Warframe"
echo "*************************************************"
rm -R $GAMEDIR

echo "*************************************************"
echo "Warframe has been successfully removed."
echo "*************************************************"
