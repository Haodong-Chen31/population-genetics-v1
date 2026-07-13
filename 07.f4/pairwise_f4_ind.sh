#!/bin/bash

#usage: sh ~/code/f4/f4_1.sh [prefix of merged files (path)] [target pop] [poplist]

#/home/HaodongChen/xjcd/06.qpwave/sample/1240k.v04_xjcd_zh
# 读取输入文件中的所有元素到数组中
fn_1240k=$1
readarray -t tar1 < $2
readarray -t tar2 < $3
readarray -t pop_1240k < $4

tarpop1=$(basename $2 _sample.pop)
tarpop2=$(basename $3 _sample.pop)
#读取人群，pop不包含目标人群和自己

DIR=$(pwd)

# 遍历数组中的每个元素
#1240k tar1 tar2
for p in ${pop_1240k[@]};do
  for ((i=0; i<${#tar1[@]}; i++)); do
    for ((j=0; j<${#tar1[@]}; j++)); do
      # ref两两组合，target放首
      echo "Mbuti.DG ${p} ${tar1[$i]} ${tar1[$j]}"
    done
  done
done > pairwise_f4_${tarpop1}.pop
cat pairwise_f4_${tarpop1}.pop | awk '$1 != $2 && $1 != $3 && $1 != $4 && $2 != $3 && $2 != $4 && $3 != $4' > tmp.pop
rm pairwise_f4_${tarpop1}.pop; mv tmp.pop pairwise_f4_${tarpop1}.pop

for p in ${pop_1240k[@]};do
  for ((i=0; i<${#tar2[@]}; i++)); do
    for ((j=0; j<${#tar2[@]}; j++)); do
      # ref两两组合，target放首
      echo "Mbuti.DG ${p} ${tar2[$i]} ${tar2[$j]}"
    done
  done
done > pairwise_f4_${tarpop2}.pop
cat pairwise_f4_${tarpop2}.pop | awk '$1 != $2 && $1 != $3 && $1 != $4 && $2 != $3 && $2 != $4 && $3 != $4' > tmp.pop
rm pairwise_f4_${tarpop2}.pop; mv tmp.pop pairwise_f4_${tarpop2}.pop

for t in ${tarpop1} ${tarpop2};do
  cat<<EOF>pairwise_f4_${t}.par
genotypename: ${fn_1240k}.geno
snpname:      ${fn_1240k}.snp
indivname:    ${fn_1240k}.ind
popfilename:  pairwise_f4_${t}.pop
f4mode:       YES
EOF
  qpDstat -p pairwise_f4_${t}.par > pairwise_f4_${t}.result
  grep result pairwise_f4_${t}.result | awk '{print $3" "$4" "$7}' > pairwise_f4_${t}_z.txt
  grep result pairwise_f4_${t}.result | awk '{print $2","$3","$4","$5","$6","$7","$8","$9","$10}' |\
  sed '1i\W,X,Y,Z,D-stat,z-score,BABA,ABBA,SNPs' > pairwise_f4_${t}.csv
done
