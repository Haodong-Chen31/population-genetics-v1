#!/bin/bash

#usage: sh pipe_prep.sh [target pops] [left pops]

fn=$1
mapfile -t target < $2
mapfile -t left < $3
dir=$(pwd)

rm -rf ${dir}/runfile ${dir}/result
mkdir -p ${dir}/runfile ${dir}/result
> runfile/alder.parl

for t in ${target[@]}; do
  for ((i=0; i<${#left[@]}; i++)); do
    for ((j=i+1; j<${#left[@]}; j++)); do
	cat<<EOF>runfile/${t}-${left[i]}-${left[j]}.par
genotypename:	${fn}.geno
snpname:	${fn}.snp
indivname:	${fn}.ind
admixpop:	${t}
refpops:	${left[i]};${left[j]}
checkmap:       NO
mindis:		0.005
binsize:        0.0005
mincount:	2
jackknife:	YES
raw_outname:	result/${t}-${left[i]}-${left[j]}.result
EOF
	echo "alder -p ${dir}/runfile/${t}-${left[i]}-${left[j]}.par > ${dir}/result/${t}-${left[i]}-${left[j]}.log" >> runfile/alder.parl
    done
  done
done

cat runfile/alder.parl | parallel -j 10
