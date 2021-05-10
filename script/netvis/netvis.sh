#!/bin/bash
freq=$1
ncount=$2
ninfo=$3


Rscript extract.edges.R $freq
Rscript get_net.R $freq $ncount
python run_vis.py $freq $ncount $ninfo
python combine_net.py $freq $ncount



xdg-open ../../data/netvis/net.html
