#!/bin/bash

#预先准备一个poplist包含treemix图中所有人群
#注：根为Mbuti.DG
#usage:sh keep_plink_file_treemix.sh [merged file name(path)] [poplist for treemix]

DIR=$(pwd)
fn=$1
poplist=$2

#extract
PARFILE=$DIR/parextract
cat >$PARFILE<<EOF
genotypename:   ${fn}.geno
snpname:        ${fn}.snp
indivname:      ${fn}.ind
outputformat:   EIGENSTRAT
genooutfilename:        ${DIR}/treemix.geno
snpoutfilename: ${DIR}/treemix.snp
indoutfilename: ${DIR}/treemix.ind
poplistname:    ${DIR}/${poplist}
hashcheck:      NO
strandcheck:    NO
allowdups:      YES
EOF
convertf -p $PARFILE

#convert eigen2plink
PARFILE=$DIR/parconvert_eigen2plink
cat >$PARFILE<<EOF
genotypename:   ${DIR}/treemix.geno
snpname:        ${DIR}/treemix.snp
indivname:      ${DIR}/treemix.ind
outputformat:   PACKEDPED
genooutfilename:        ${DIR}/treemix.bed
snpoutfilename: ${DIR}/treemix.bim
indoutfilename: ${DIR}/treemix.fam
EOF
convertf -p $PARFILE

#.fam文件改对
cat ${DIR}/treemix.ind > ${DIR}/1.txt
printf "\n" >> ${DIR}/1.txt;cat ${DIR}/treemix.ind >> ${DIR}/1.txt
awk -F " " 'NR==FNR{pop[$1]=$3}NR>FNR{print pop[$2],substr($0,index($0,$2))}' ${DIR}/1.txt ${DIR}/treemix.fam > ${DIR}/treemix_1.fam
rm ${DIR}/treemix.fam ${DIR}/1.txt
mv ${DIR}/treemix_1.fam ${DIR}/treemix.fam

cat $DIR/treemix.fam | awk -F " " '{print $1,$2,$1}' > $DIR/plink.clst
plink --bfile $DIR/treemix --missing --freq --within $DIR/plink.clst --allow-no-sex --allow-extra-chr 0 --out $DIR/plink
gzip $DIR/plink.frq.strat
python2 /home/HaodongChen/code/treemix/plink2treemix.py $DIR/plink.frq.strat.gz $DIR/treemix.frq.gz

#treemix
i=$(seq 0 10)  # migration
j=$(seq 1 20)  # bootstrap
parallel_thread=$(echo ${j} | tr ' ' '\n' | sort -nr | head -n 1 | awk '{print int($1 / 2)}') 

for a in ${i};do
  mkdir result${a} ; cp treemix_plot.R plotting_funcs.R result${a}
  for b in ${j};do
    echo "treemix -i ${DIR}/treemix.frq.gz -root Mbuti.DG -m ${a} -se -bootstrap -q 10 -k 500 -global -noss -o ${DIR}/result${a}/Treemix${a}_${b} > ${DIR}/result${a}/Treemix${a}_${b}.log"
  done
done > ${DIR}/treemix.parl

cat ${DIR}/treemix.parl | parallel -j ${parallel_thread}

wait

#treemix plot
for a in ${i};do
  cd ${DIR}/result${a}
  grep 'Exiting ln(likelihood)' *.llik | sort -k7 > likelihood_${a}.txt
  for b in ${j};do
    Rscript treemix_plot.R Treemix${a}_${b} ${DIR}/${poplist}
    mv Rplots.pdf Treemix${a}_${b}_residuals.pdf
  done
  cd ${DIR}
done &&
cat result*/likelihood_*.txt > likelihood.txt
