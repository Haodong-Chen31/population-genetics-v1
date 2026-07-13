#!/bin/bash

#usage: sh ~/code/convert_merge/merge_HO_1240k.sh [prefix of filename] [prefix of merged HO filename] [prefix of merged 1240k filename]
DIR=$(pwd)
fn=$1
FILENAME_HO=$2
FILENAME_1240k=$3
#name of snp: "chr_pos"
fn_HO=/home/HaodongChen/database/HO.v05
fn_1240k=/home/HaodongChen/database/1240k.v04

##MERGE WITH HO
PARFILE=par.merge_HO_${fn}
cat >${PARFILE}<<EOF
geno1:	${DIR}/${fn}.geno
snp1:	${DIR}/${fn}.snp
ind1:	${DIR}/${fn}.ind
geno2:	${fn_HO}.geno
snp2:	${fn_HO}.snp
ind2:	${fn_HO}.ind
genooutfilename:	${DIR}/${FILENAME_HO}.geno
snpoutfilename:	${DIR}/${FILENAME_HO}.snp
indoutfilename:	${DIR}/${FILENAME_HO}.ind
hashcheck:	NO
strandcheck:	NO
allowdups:	YES
EOF
mergeit -p ${PARFILE}

##MERGE WITH 1240k
PARFILE=par.merge_1240k_${fn}
cat >${PARFILE}<<EOF
geno1:	${DIR}/${fn}.geno
snp1:	${DIR}/${fn}.snp
ind1:	${DIR}/${fn}.ind
geno2:	${fn_1240k}.geno
snp2:	${fn_1240k}.snp
ind2:	${fn_1240k}.ind
genooutfilename:	${DIR}/${FILENAME_1240k}.geno
snpoutfilename:	${DIR}/${FILENAME_1240k}.snp
indoutfilename:	${DIR}/${FILENAME_1240k}.ind
hashcheck:	NO
strandcheck:	NO
allowdups:	YES
EOF
mergeit -p ${PARFILE}
