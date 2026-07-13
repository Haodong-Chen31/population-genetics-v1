#!/bin/bash

DIR=$(pwd)
fn=$1
mapfile -t target < $2
mapfile -t source1 < $3
mapfile -t source2 < $4

#admixlist
for t in ${target[@]}; do
  for ((i=0; i<${#source1[@]}; i++)); do
    for ((j=0; j<${#source2[@]}; j++)); do
      echo "${source1[i]} ${source2[j]} ${t} ${t}-${source1[i]}-${source2[j]}"
    done
  done
done > admix_list

#pardates
cat<<EOF>par_dates
indivname:	${fn}.ind
snpname:	${fn}.snp
genotypename:	${fn}.geno
admixlist:	${DIR}/admix_list
binsize:  0.001
maxdis:  1.0
seed:  666
runmode:  1
chithresh:  0.0
mincount:  1
zdipcorrmode:  YES
qbin:  10
runfit:  YES
afffit:  YES
lovalfit:  0.45
checkmap: NO
EOF
dates -p par_dates > dates.log

echo "target,source1,source2,mean,std.err,Z" > dates_result.csv
for targ in ${target[@]}; do
  for ((i=0; i<${#source1[@]}; i++)); do
    for ((j=0; j<${#source2[@]}; j++)); do
      printf "${targ},${source1[i]},${source2[j]}," >> dates_result.csv
      cat ./${targ}-${source1[i]}-${source2[j]}/${targ}.jout | grep "mean:" | awk '{print $2","$5","$7}' >> dates_result.csv
#      awk '/mean:/ {print $2","$5","$7}' "./${targ}-${s1}-${s2}/${targ}.jout" >> dates_result.csv
    done
  done
done

