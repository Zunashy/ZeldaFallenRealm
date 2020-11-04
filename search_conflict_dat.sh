#! /bin/bash
# AUTHOR : SaniTOS

# Cherche des conflits dans les fichier .dat

RED="\e[91m"
RESET="\e[39m"
GREEN="\e[92m"
BOLD="\e[1m"
NORMAL="\e[0m"

cd "${1:-.}" || exit 1
for file in $(find . -name "*.dat");
do
   if grep -q "<<<<<<< HEAD" $file; then
         echo -e "[ $RED KO $RESET ] $BOLD $file $NORMAL"
   else
         echo -e "[ $GREEN OK $RESET ] $BOLD $file $NORMAL"
   fi
done
