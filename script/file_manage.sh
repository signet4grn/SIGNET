#!/bin/bash
##This is a collection of file management functions

#Check whether they are in the same directory 
file_compare(){
fil1=$1
file2=$2

if [[ "$file1" == *\/* ]];then DIR1=${file1%/*};else DIR1=$(pwd); fi
if [[ "$file2" == *\/* ]];then DIR2=${file2%/*};else DIR2=$(pwd); fi

##Handle the case when it's empty
if [[ -z $DIR1 ]]; then DIR1=$(pwd); fi
if [[ -z $DIR2 ]]; then DIR2=$(pwd); fi

if [[ $DIR1 -ef $DIR2 ]];then
echo "Please make sure that the temporary files and the result files are in different folders"
exit -1 
fi

}

#Add a prefix to the files in the current directory
file_prefix(){
for f in * ;do mv -- "$f" "$1_$f"; done
}

#This function takes the user defined output and default path,  check whether it exists, prevent to be the subdirectory of the default path.
file_check(){
##Check if the directory exists

if [[ "$1" == *\/* ]];then DIR1=${1%/*};else DIR1=$(pwd); fi

##Handle the case when it's empty
if [[ -z $DIR1 ]]; then DIR1=$(pwd); fi

if [[ ! -d $DIR1 ]]; then 
echo "The directory $DIR1 doesn't exist"
exit -1 
fi

DIR1=$(readlink -f $DIR1)

##Check whether it's in the subdirectory 
if [[ $DIR1 == $2* ]];then
echo "The temporary files or result files can't be put in the subdirectories of default directories"
exit -1
fi

qyn=0

while [[ qyn -eq 0 ]]; do

qyn=1

if compgen -G "$1"_"*" >> /dev/null; then
read -p "There exists files with prefix "$1" already, overwriting them? Enter Y to continue, N to exit. [Y/N]: "  yn

case $yn in
Y|Yes|y|yes ) rm -rf "$1"_*;;
N|No|n|no ) exit -1;;
* ) qyn=0
    echo -n "Please choose between Y or N: "
    read yn;;
esac
fi

done
}


## Transfer file from the default directory to out directory
file_trans(){

default_file=$1
out_file=$2

for f in $1_*; do
outname=$2_${f#$1_}
if ! [ "$f" -ef "$outname" ];then 
mv -n "$f" "$outname"; 
fi
done

}

export -f file_compare file_prefix file_check file_trans
