#! /bin/bash

function gpush(){
git add .
git commit -a -m "$1"
git pull
git push origin master
}
