#!/bin/bash

module load utilities
module load parafly

#cd ../../data/network/stage2

#cp ../nety ./
#cp ../netx ./
#cp ../netyx_idx ./
#cp ../IDX* ./
#cp ../SIS.R ./
#cp ../subfuns.R ./

NB=$1

#for i in $(seq 0 $NB)
#do
#  cp ../stage1/ypre$i ./
#done


cd ../../script/network
 > params_stage2.sh
#rm -rfv stage2/*
#rm -rfv ../../data/network/stage2/*
# params_stage2.sh.completed
for i in $(seq 0 $NB)
do
        A=1
        B=80
        perl -pe 's/XXbsXX/'$i'/e; s/YYfirstYY/'$A'/e; s/YYlastYY/'$B'/e' < bts2template.r > stage2/bs$i'_'$A-$B.r
        echo 'Rscript ./stage2/bs'$i'_'$A-$B'.r ' >> params_stage2.sh
done

cd ../../script/network
##Use ParaFly to schedule our work
#nohup ParaFly -c params_stage2.txt -CPU 10 &
ParaFly -c params_stage2.sh -CPU 10 
