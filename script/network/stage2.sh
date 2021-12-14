#!/bin/bash

cd $SIGNET_TMP_ROOT/tmpn

#if [ ! -d "stage2" ];then
mkdir stage2
#fi

$SIGNET_SCRIPT_ROOT/network/bts2gensub.sh
