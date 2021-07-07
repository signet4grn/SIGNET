#!/bin/bash
nboots=$1
memory=$2
walltime=$3
ncores=$4
queue=$5

cd $SIGNET_TMP_ROOT/tmpn

if [ ! -d "stage1" ];then
mkdir stage1
fi

$SIGNET_SCRIPT_ROOT/network/bts1gensub.sh $nboots $memory $walltime $ncores $queue
