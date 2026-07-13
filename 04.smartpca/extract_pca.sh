#!/usr/bin/bash
#usage: sh extract_pca.sh [merged file name(path)] [poplist for pca] [modern pop]

DIR=$(pwd)
fn=$1
POP=$2
POP_M=$3

##extract
cat<<EOF>parextract
genotypename:	${fn}.geno
snpname:	${fn}.snp
indivname:	${fn}.ind
outputformat:	EIGENSTRAT
genooutfilename:	${DIR}/smartpca.geno
snpoutfilename:	${DIR}/smartpca.snp
indoutfilename:	${DIR}/smartpca.ind
poplistname:	${DIR}/${POP}
hashcheck:	NO
strandcheck:	NO
allowdups:	YES
EOF
convertf -p parextract

##smartpca
cat<<EOF>parsmartpca
genotypename:	${DIR}/smartpca.geno
snpname:	${DIR}/smartpca.snp
indivname:	${DIR}/smartpca.ind
evecoutname:	${DIR}/smartpca.evec
evaloutname:	${DIR}/smartpca.eval
poplistname:	${DIR}/${POP_M}
lsqproject:	YES
numoutevec:	4
numoutlieriter:	0
altnormstyle:	NO
EOF
smartpca -p parsmartpca
