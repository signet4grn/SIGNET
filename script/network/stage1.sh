#!/bin/bash

module load utilities
module load parafly

NB=$1

cd ../../data/network




NGENES=$(wc -l uniqy_idx | cut -d " " -f1)

cd ../../script/network
 > params_stage1.sh
for i in $(seq 0 $NB)
do
    perl -pe 's/XXbsXX/'$i'/e; s/YYfirstYY/1/e; s/YYlastYY/'$NGENES'/e' < bts1template.r > ./stage1/bs$i.R
    echo 'Rscript ./stage1/bs'$i'.R' >> params_stage1.sh
done

wait
##Use ParaFly to schedule our work
ParaFly -c params_stage1.sh -CPU 10 

wait

cd ../../data/network/stage1

for i in $(seq 0 $NB)
do
  paste -d' ' $(find ./ -name 'ypre'$i'_*' | sort -V) > ypre$i
done

cut -d ' ' -f1-5 ypre0 | head
