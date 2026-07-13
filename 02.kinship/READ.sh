#!/bin/bash

tplink=$1

#READscript.R放在运行路径下
cp ~/code/kinship/READscript.R .

python2 ~/code/kinship/READ.py $tplink
