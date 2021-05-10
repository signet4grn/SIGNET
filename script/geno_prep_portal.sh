#!/bin/bash


usage() {
    echo "Usage:"
    echo "  genotype preprocess [-p PED_FILE] [-m MAP_FILE]"
    echo "Description:"
    echo "    -p, set ped file"
    echo "    -m, set map file"
    exit -1
}

pedfile=$(./config_controller.sh -l Genotype ped.file);
mapfile=$(./config_controller.sh -l Genotype map.file);

while getopts u:t:c:d:p: option
do
   case "${option}"  in  
                p) pedfile=${OPTARG};;
                m) mapfile=${OPTARG};;
                h) usage;;
                ?) usage;;
   esac
    
done



echo "ped.file: "$pedfile
echo "map.file: "$mapfile

cd ./geno-prep
./geno-prep.sh $pedfile $mapfile









