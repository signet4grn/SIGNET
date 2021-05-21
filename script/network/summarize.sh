#!/bin/bash


cd ../../data/network/stage2
NB=$1

for i in $(seq 0 $NB)
do
  cat $(find ./ -name 'AdjMat'$i'_*' | sort -V) > res/AdjMat$i
done 


for i in $(seq 0 $NB)
do
  cat $(find ./ -name 'CoeffMat'$i'_*' | sort -V) > res/CoeffMat$i
done

wait

cd ../../../script/network

Rscript summary.boot.R
