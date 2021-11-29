#!/bin/bash

file_purge(){
file=$1

qyn=0

while [[ qyn -eq 0 ]]; do

qyn=1

if [[ -d $file ]]; then
read -p "$file alreay exists, you could back them up or overwriting them. Overwriting them? Enter Y to overwrite, N to exit. [Y/N]: "  yn

case $yn in
Y|Yes|y|yes ) rm -rf $file;;
N|No|n|no ) exit -1;;
* ) qyn=0
    echo -n "Please choose between Y or N: "
    read yn;;
esac
fi

done

mkdir $file

}

# Input a directory with prefix, check whether it exists
dir_check(){
##Check if the directory exists

if [[ "$1" == *\/* ]];then DIR1=${1%/*};else DIR1=$(pwd); fi

##Handle the case when it's empty
if [[ -z $DIR1 ]]; then DIR1=$(pwd); fi

if [[ ! -d $DIR1 ]]; then
echo "The directory $DIR1 doesn't exist, note that prefix applies"
exit -1
fi

}

export -f file_purge dir_check
