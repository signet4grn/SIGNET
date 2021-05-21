#!/bin/bash

usage() {
    echo "Usage:"
    echo "  geno-prep [-p PED_FILE] [-m MAP_FILE]"
    echo "Description:"
    echo "    -p, set ped file"
    echo "    -m, set map file"
    exit -1
}

pedfile=$(./config_controller.sh -l geno,ped.file);
mapfile=$(./config_controller.sh -l geno,map.file);

while getopts p:m:h:? option
do
   case "${option}"  in  
                p) pedfile=${OPTARG};;
                m) mapfile=${OPTARG};;
		h) usage;;
                ?) usage;;
   esac
    
done

##Directly modify the files in the parameter files   
./config_controller.sh -m geno,ped.file $pedfile
./config_controller.sh -m geno,map.file $mapfile

echo "ped.file: "$pedfile
echo "map.file: "$mapfile

cd ./geno-prep
./geno-prep.sh



