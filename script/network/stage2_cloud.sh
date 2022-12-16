#!/bin/bash

cd $SIGNET_TMP_ROOT/tmpn

#if [ ! -d "stage2" ];then
mkdir -p stage2
#fi

$SIGNET_SCRIPT_ROOT/network/bts2gensub_cloud.sh
