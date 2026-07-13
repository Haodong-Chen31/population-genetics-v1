#!/bin/bash

#usage: sh ~/code/f4/f4_1.sh [prefix of merged files (path)] [target pop] [poplist]

# 读取输入文件中的所有元素到数组中
fn=$1
#读取人群，pop包含目标人群
readarray -t refpop < $2
readarray -t pop1 < $3
readarray -t pop2 < $4
DIR=$(pwd)

# 遍历数组中的每个元素
#1240k
for p in ${refpop[@]};do
  for p1 in ${pop1[@]}; do
    for p2 in ${pop2[@]}; do
      # 
      echo "Mbuti.DG ${p} ${p1} ${p2}"
    done
  done
done > pairwise_f4.pop
cat pairwise_f4.pop | awk '$1 != $2 && $1 != $3 && $1 != $4 && $2 != $3 && $2 != $4 && $3 != $4' > tmp.pop
rm pairwise_f4.pop; mv tmp.pop pairwise_f4.pop

cat<<EOF>pairwise_f4.par
genotypename: ${fn}.geno
snpname:      ${fn}.snp
indivname:    ${fn}.ind
popfilename:  pairwise_f4.pop
f4mode:       YES
EOF

qpDstat -p pairwise_f4.par > pairwise_f4.result
grep result pairwise_f4.result | awk '{print $3" "$4" "$7}' > pairwise_f4_z.txt
grep result pairwise_f4.result | awk '{print $2","$3","$4","$5","$6","$7","$8","$9","$10}' |\
sed '1i\W,X,Y,Z,D-stat,z-score,BABA,ABBA,SNPs' > pairwise_f4.csv
