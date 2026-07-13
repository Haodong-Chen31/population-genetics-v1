#!/bin/sh

DIR=$(pwd)
#treemix
i=$(seq 0 10)  # migration
j=$(seq 1 20)  # bootstrap
parallel_thread=$(echo ${j} | tr ' ' '\n' | sort -nr | head -n 1 | awk '{print int($1 / 4)}')

for a in ${i};do
  mkdir -p result${a} ; cp treemix_plot.R plotting_funcs.R result${a}
  for b in ${j};do
    echo "treemix -i ${DIR}/treemix.frq.gz -root Mbuti.DG -m ${a} -se -bootstrap -q 10 -k 500 -global -noss -o ${DIR}/result${a}/Treemix${a}_${b} > ${DIR}/result${a}/Treemix${a}_${b}.log"
  done
done > ${DIR}/treemix2.parl

cat ${DIR}/treemix2.parl | parallel -j ${parallel_thread}

#treemix plot
for a in ${i};do
  cd result${a}
  grep 'Exiting ln(likelihood)' *.llik | sort -k7 > likelihood_${a}.txt
  for b in ${j};do
    Rscript treemix_plot.R Treemix${a}_${b}
  done
  cd ${DIR}
done &&
cat result*/likelihood_*.txt > likelihood.txt

