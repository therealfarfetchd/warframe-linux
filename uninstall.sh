#!/bin/bash

# Change to your preferred installation directory
GAMEDIR="${HOME}/Warframe"

INSTDIR_PTR="${HOME}/.local/share/warframe-instdir"

test -f "${INSTDIR_PTR}" && GAMEDIR="$(cat "${INSTDIR_PTR}")"

function rm_noisy() {
  echo "*************************************************"
  echo "Removing $1"
  echo "*************************************************"
  rm -R "$1"
}

echo "*************************************************"
echo "The next few steps will remove all shortcuts and warframe files."
echo "*************************************************"

rm_noisy "${HOME}/bin/warframe"
rm_noisy "${HOME}/.local/share/pixmaps/warframe.png"
rm_noisy "${HOME}/.local/share/applications/warframe.desktop"
rm_noisy "${HOME}/Desktop/warframe.desktop"
rm_noisy "${GAMEDIR}"
rm_noisy "${INSTDIR_PTR}"

echo "*************************************************"
echo "Warframe has been successfully removed."
echo "*************************************************"
