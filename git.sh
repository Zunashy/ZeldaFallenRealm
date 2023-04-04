#! /bin/bash
RED="\e[91m"
RESET="\e[39m"
GREEN="\e[92m"
BOLD="\e[1m"
NORMAL="\e[0m"
declare -a DAT_TAB
declare -a LUA_TAB


function dat(){
cd "${1:-.}" || exit 1
for file in $(find . -name "*.dat");
do
   if grep -q "<<<<<<< HEAD" $file; then
	DAT_TAB=( "${DAT_TAB[@]}" "$file" )
         echo -e "[ $RED KO $RESET ] $BOLD $file $NORMAL"
   else
         echo -e "[ $GREEN OK $RESET ] $BOLD $file $NORMAL"
   fi
done
if [ ${#DAT_TAB} -lt 1 ]; then echo ""; echo -e "$GREEN $BOLD[SUCC]$NORMAL $RESET There is no conflict ! =) $NORMAL"
else echo ""
     echo -e "$RED $BOLD[FAIL]$NORMAL $RESET File(s) with conflicts : " 
     echo -e $DAT_TAB
fi
}

function lua(){
cd "${1:-.}" || exit 1
for file in $(find . -name "*.lua");
do
   if grep -q "<<<<<<< HEAD" $file; then
	LUA_TAB=( "${LUA_TAB[@]}" "$file" )
         echo -e "[ $RED KO $RESET ] $BOLD $file $NORMAL"
   else
         echo -e "[ $GREEN OK $RESET ] $BOLD $file $NORMAL"
   fi
done
if [ ${#LUA_TAB} -lt 1 ]; then echo ""; echo -e "$GREEN $BOLD[SUCC]$NORMAL $RESET There is no conflict ! =) $NORMAL"
else echo ""
     echo -e "$RED $BOLD[FAIL]$NORMAL $RESET File(s) with conflicts : "
     echo -e $LUA_TAB
fi
}



function gpush(){
#git add .
git commit -a -m "$1"
git pull
git push origin master
}
