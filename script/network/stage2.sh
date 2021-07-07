#!/bin/bash
nboots=$1
memory=$2
walltime=$3
ncores=$4
queue=$5

cd $SIGNET_TMP_ROOT/tmpn

if [ ! -d "stage2" ];then
mkdir stage2
fi

$SIGNET_SCRIPT_ROOT/network/bts2gensub.sh $nboots $memory $walltime $ncores $queue
