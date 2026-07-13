#!/bin/bash
pop=Mogou
dir=/home/XiaominYang/Mogou/tribam
snpdir=/home/XiaominYang/Mogou/snpfile
outdir=/home/XiaominYang/Mogou/kinship
ref_snp=/home/XiaominYang/ref/map/1240k.XY.snp
kinship=/home/XiaominYang/sh/kinship

mkdir -p kinship
#using READ to eastime kinship
#convertf PACKPED geno/snp/ind -> bed/bim/fam
cd ${outdir}
mkdir -p READ; cd READ
printf "DIR1: ${snpdir}\n" > parconvertf 
printf "DIR2: ${outdir}\n" >> parconvertf 
printf "S1: ${pop}\n" >> parconvertf 
printf "genotypename: DIR1/S1.geno\n" >> parconvertf
printf "snpname: DIR1/S1.snp\n" >> parconvertf
printf "indivname: DIR1/S1.ind\n" >> parconvertf 
printf "outputformat: PACKEDPED\n" >> parconvertf
printf "genotypeoutname: DIR2/S1.bed\n" >> parconvertf
printf "snpoutname: DIR2/S1.bim\n" >> parconvertf
printf "indivoutname: DIR2/S1.fam\n" >> parconvertf
convertf -p parconvertf &&
plink --bfile ${pop}  --make-bed --out new &&
plink --bfile new --recode transpose --out new && 
python2 ${kinship}/READ.py new

# using lcmlkin to estimate kinship
cd ${dir}
ls ./ | grep ".bam$" > bam.list
cat ${ref_snp} | awk 'BEGIN{FS=" ";OFS="\t";}{print $2,$4,$5,$6;}' > ${outdir}/SNP.list &&
python ${kinship}/SNPbam2vcf.py3 bam.list ${outdir}/${pop}.vcf ${outdir}/SNP.list &&
lcmlkin -i ${outdir}/${pop}.vcf -o ${outdir}/${pop}.relate -g all -t 8 &&
Rscript  ${kinship}/lcMLkin.r $outdir ${pop}


#using tkgwv2 to estimate kinship
bamdir=/home/XiaominYang/Mogou/tribam
ref=${kinship}/tkgwv2/genomeWideVariants_hg19
ref_fa=/home/XiaominYang/ref/human/hs37d5.fa
mkdir ${outdir}/tkgwv2; cd ${outdir}/tkgwv2
cd ${bamfile}
Rscript ~/bin/downsampleBam.R &&
mv *_subsampled.bam ${outdir}/tkgwv2
Python ${kinship}/tkgwv2/TKGWV2.py bam2plink \
    --referenceGenome ${ref_fa} \
    --gwvList  ${ref}/1000GP3_22M_noFixed_noChr.bed \
    --gwvPlink ${ref}/DummyDataset_EUR_22M_noFixed pp \
    --bamExtension ${bamdir}/*.bam 
   
Python ${kinship}/tkgwv2/TKGWV2.py plink2tkrelated  --freqFile ${ref}/1000GP3_EUR_22M_noFixed.frq 

rm *_subsampled.bam *.frq *.tped
