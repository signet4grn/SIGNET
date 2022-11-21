#!/bin/bash

cd $SIGNET_TMP_ROOT/tmpn

#if [ ! -d "stage1" ];then
mkdir stage1
#fi

$SIGNET_SCRIPT_ROOT/network/bts1gensub_cloud.sh
