#!/bin/sh

# using lcmlkin to estimate kinship
cd ${dir}
ls ./ | grep ".bam$" > bam.list
cat ${ref_snp} | awk 'BEGIN{FS=" ";OFS="\t";}{print $2,$4,$5,$6;}' > ${outdir}/SNP.list &&
python ${kinship}/SNPbam2vcf.py3 bam.list ${outdir}/${pop}.vcf ${outdir}/SNP.list &&
lcmlkin -i ${outdir}/${pop}.vcf -o ${outdir}/${pop}.relate -g all -t 8 &&
Rscript  ${kinship}/lcMLkin.r $outdir ${pop}

#!/bin/bash

DIR=$1
vcf=$2
vcf_out=$3
python ~/code/kinship/SNPbam2vcf.py $DIR/bam.list $vcf SNP.list
vcftools --vcf $vcf --thin 100000 --remove-indels --maf 0.05 --recode --recode-INFO-all --out $vcf_out
lcmlkin -i $vcf_out -o output.relate -g all -t 8 (-u )
