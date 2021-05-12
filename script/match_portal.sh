#!/bin/bash


usage() {
    echo "Usage:"
    echo "  match gene expression and genotype data"
    echo "Description:"
    echo "    -m | --ma, minor alleles threshold"
    exit -1
}

pedfile=$(./config_controller.sh -l Genotype ped.file);
ma=$(./config_controller.sh -l Genotype map.file);

while getopts u:t:c:d:p: option
do
   case "${option}"  in  
                m) ma=${OPTARG};;
                h) usage;;
                ?) usage;;
   esac
    
done


cd ./match
./match.sh $ma









