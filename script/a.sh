#!/bin/bash

echo -n The directory this command was excuted from is:
ROOT=$(cd $(dirname $0); /bin/pwd)
echo $ROOT
