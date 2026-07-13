#!/bin/bash

#usage: sh merge.sh [prefix of file1] [prefix of file2] [prefix of merged file]

fn1=$1
fn2=$2
fn_merged=$3
PARFILE=$(pwd)/parmerge

cat<<EOF>$PARFILE
geno1:	${fn1}.geno
snp1:	${fn1}.snp
ind1:	${fn1}.ind
geno2:	${fn2}.geno
snp2:	${fn2}.snp
ind2:	${fn2}.ind
genooutfilename:	$(pwd)/${fn_merged}.geno
snpoutfilename:		$(pwd)/${fn_merged}.snp
indoutfilename:		$(pwd)/${fn_merged}.ind
hashcheck:	NO
strandcheck:	NO
allowdups:	YES
EOF

mergeit -p ${PARFILE}
