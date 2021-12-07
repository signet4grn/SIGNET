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

echo -e "\n"
}

# Input a directory with prefix, check whether it exists

dir_check(){
##Check if the directory exists

if [[ "$1" == *\/* ]];then DIR=${1%/*};else DIR=$(pwd); fi

##Handle the case when it's empty
if [[ -z $DIR ]]; then DIR=$(pwd); fi

FILE=${1#$DIR/}

if [[ ! -d $DIR ]]; then
echo "The directory $DIR doesn't exist, note that prefix applies"
exit -1
fi

FDIR=$(readlink -f $DIR)

echo ${FDIR}/${FILE}

}

export -f file_purge dir_check
