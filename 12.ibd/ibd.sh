#!/bin/bash
#IBD
#usage: sh ~/code/ibd/ [output directory] [HO file] [poplist]
DIR=$(pwd)
fn=$1
poplist=$2

#software
softwarepath=/home/HaodongChen/software/ibd
refineibd=${softwarepath}/refined-ibd.17Jan20.102.jar
mergeibd=${softwarepath}/merge-ibd-segments.17Jan20.102.jar
map=${softwarepath}/plink.GRCh37.map/combined_GRCh37.map

#extract&convert
mkdir -p ${DIR}/data

cat >extract.par<<EOF
genotypename:	${fn}.geno
snpname:	${fn}.snp
indivname:	${fn}.ind
outputformat:	EIGENSTRAT
genooutfilename:	${DIR}/data/ibd.geno
snpoutfilename:	${DIR}/data/ibd.snp
indoutfilename:	${DIR}/data/ibd.ind
poplistname:	${DIR}/${poplist}
hashcheck:	NO
strandcheck:	NO
allowdups:	YES
EOF
convertf -p extract.par

#convert into bfile
cd ${DIR}/data
cat >convertf.par<<EOF
genotypename:	ibd.geno
snpname:	ibd.snp
indivname:	ibd.ind
outputformat:	PACKEDPED
genooutfilename:	ibd.bed
snpoutfilename:	ibd.bim
indoutfilename:	ibd.fam
hashcheck:	NO
strandcheck:	NO
allowdups:	YES
EOF
convertf -p convertf.par

#改fam文件
awk -F " " 'NR==FNR{pop[$1]=$3}NR>FNR{print pop[$2],substr($0,index($0,$2))}' ibd.ind ibd.fam > ibd_1.fam
rm ibd.fam
mv ibd_1.fam ibd.fam

##质控
plink --bfile ibd --geno 0.05 --mind 0.05 --maf 0.05 --autosome --snps-only just-acgt \
--allow-no-sex --nonfounders --recode vcf-iid bgz --out ibd_qc
bcftools index ibd_qc.vcf.gz

# Split VCF file by chromosome
for i in {1..22}; do
  bcftools view -O z -o chr${i}.vcf.gz -r ${i} ibd_qc.vcf.gz
done

#
cd ${DIR}
mkdir -p ${DIR}/tmp ${DIR}/1.phase
cd ${DIR}/1.phase

#Shapeit
for x in {1..22}; do
	shapeit --input-vcf ${DIR}/data/chr${x}.vcf.gz \
	-M ${softwarepath}/genetic_map/genetic_map_adjust_chr${x}.txt \
	-O ibd.chr${x}.phased \
	--output-log chr${x}.log \
	--burn 10 --prune 10 --main 30 \
	--seed 123456789 --thread 8
done
cp ibd.chr1.phased.sample ${DIR}/tmp

#把.sample文件中的ID改成pop名+序号
for x in {1..22};do 
	awk 'NR <= 2 { print; next } { $1 = $1 NR-2; print }' ${DIR}/tmp/ibd.chr1.phased.sample > ibd.chr${x}.phased.sample
done
rm -r ${DIR}/tmp
#“.phased”（shapeit标准输出格式）转vcf
for x in {1..22}; do
	shapeit -convert --input-haps ibd.chr${x}.phased --output-vcf ibd.chr${x}.vcf --output-log chr${x}.vcf.log 
done

#压缩并索引phase文件夹中的各个vcf
for x in {1..22}; do
  bgzip -c ibd.chr${x}.vcf > ibd.chr${x}.vcf.gz
  bcftools index ibd.chr${x}.vcf.gz
done

#合并为一个vcf
bcftools concat -O z -o ibd.combined.vcf.gz ibd.chr{1..22}.vcf.gz
#cat ${softwarepath}/plink.GRCh37.map/plink.chr{1..22}.GRCh37.map > ${softwarepath}/plink.GRCh37.map/combined_genetic_map.map

#
mkdir -p ${DIR}/2.refined_ibd ${DIR}/3.merge_ibd
combinedvcf=${DIR}/1.phase/ibd.combined.vcf.gz

#refined-ibd
cd ${DIR}/2.refined_ibd
java -Xmx2026m -jar ${refineibd} \
 gt=${combinedvcf} \
 map=${map} \
 out=ibd_segments \
 length=0.1
gunzip -c ibd_segments.ibd.gz > ibd_segments.ibd

#merge-ibd
cd ${DIR}/3.merge_ibd
cat ${DIR}/2.refined_ibd/ibd_segments.ibd |\
 java -Xmx12g -Xms12g -jar ${mergeibd} ${combinedvcf} ${map} 0.6 1 > merged_ibd_segments.ibd
