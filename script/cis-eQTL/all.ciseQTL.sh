#!/bin/bash

wait
alpha=$1
echo "Combining the result..."
cd ../../data/cis-eQTL
paste -d' ' common.eQTLdata0 low.eQTLdata0 > all.eQTL.data
cd ../../script/cis-eQTL
Rscript all.ciseQTL.r $alpha
