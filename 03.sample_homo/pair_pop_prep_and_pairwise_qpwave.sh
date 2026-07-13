#!/bin/bash

# usage: bash pair_pop_prep_and_pairwise_qpwave.sh [filenames (path)] [target pops] [thread]

fn=$1
mapfile -t elements < $2
threads=$3

DIR=$(pwd)
OUTDIR=${DIR}/result
RUNFILE_DIR=${DIR}/runfile
OUTGROUP=${DIR}/outgroup.txt

# 清空输出文件
> pair_pop.txt
> pairwise_qpwave.parl
mkdir -p ${OUTDIR} ${RUNFILE_DIR}

# 进行元素的两两自由组合&prepare parameter files for qpWave
for ((i=0; i<${#elements[@]}; i++)); do
  for ((j=i+1; j<${#elements[@]}; j++)); do
    echo "${elements[i]} ${elements[j]}" >> pair_pop.txt
    echo "${elements[i]} ${elements[j]}" | sed s/" "/"\n"/g > ${elements[i]}-${elements[j]}.pop
    echo 'genotypename: '${fn}'.geno' > ${elements[i]}-${elements[j]}.par
    echo 'snpname: '${fn}'.snp' >> ${elements[i]}-${elements[j]}.par
    echo 'indivname: '${fn}'.ind' >> ${elements[i]}-${elements[j]}.par
    echo 'popleft: '${elements[i]}'-'${elements[j]}'.pop' >> ${elements[i]}-${elements[j]}.par
    echo 'popright: '${OUTGROUP}'' >> ${elements[i]}-${elements[j]}.par
    echo -e 'allsnps: YES\ndetails: YES\nmaxrank: 7\ninbreed: NO' >> ${elements[i]}-${elements[j]}.par
    echo 'qpWave -p '${elements[i]}'-'${elements[j]}'.par > '${OUTDIR}'/'${elements[i]}'-'${elements[j]}'.log' >> pairwise_qpwave.parl
  done
done

#exit

cat pairwise_qpwave.parl | parallel -j ${threads} --joblog pairwise_qpwave.log

cd ${OUTDIR}
grep 'f4rank: 0' * | awk '{print $1" "$7" "$8}' | sed 's/.log:f4rank: tail: / /' | sed 's/-/ /' > ${DIR}/tail.txt
grep 'f4rank: 0' * | awk '{print $1","$4","$6","$8","$10","$12","$14}' | sed 's/.log:f4rank://' | sed 's/-/,/'| sed '1i\pop1,pop2,dof,chisq,tail,dofdiff,chisqdiff,taildiff' > ${DIR}/result_pairwise_qpwave.csv

cd ${DIR}
mv *-*.pop *-*.par ${RUNFILE_DIR}

