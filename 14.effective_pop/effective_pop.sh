#!/bin/bash

#用质控后且去除亲缘关系了的数据
fn=$1
DIR=$(pwd)
########################################
softwarepath=/home/HaodongChen/software/ibd
refineibd=${softwarepath}/refined-ibd.17Jan20.102.jar
mergeibd=${softwarepath}/merge-ibd-segments.17Jan20.102.jar
ibdne=${softwarepath}/ibdne.23Apr20.ae9.jar
map=${softwarepath}/plink.GRCh37.map/combined_GRCh37.map

mkdir 0.data 1.phase 2.refined_ibd 3.merge_ibd tmp

#
plink --bfile ${fn} --recode vcf-iid bgz --out ${DIR}/0.data/roma

cd ${DIR}/0.data
bcftools index roma.vcf.gz
# Split VCF file by chromosome
for i in {1..22}; do
  bcftools view -O z -o chr${i}.vcf.gz -r ${i} roma.vcf.gz
done

cd ${DIR}/1.phase
#Shapeit
for x in {1..22}; do
	shapeit --input-vcf ../0.data/chr${x}.vcf.gz \
	-M ${softwarepath}/genetic_map/genetic_map_adjust_chr${x}.txt \
	-O ibd.chr${x}.phased \
	--output-log chr${x}.log \
	--burn 10 --prune 10 --main 30 \
	--seed 123456789 --thread 8
done
cp ibd.chr1.phased.sample ../tmp

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

combinedvcf=${DIR}/1.phase/ibd.combined.vcf.gz
#refine-ibd
cd ${DIR}/2.refined_ibd
java -Xmx2026m -jar ${refineibd} \
 gt=${combinedvcf} \
 map=${map}  \
 out=ibd_segments \
 length=0.1
gunzip -c ibd_segments.ibd.gz > ibd_segments.ibd

#merge IBD
cd ${DIR}/3.merge_ibd
cat ${DIR}/2.refined_ibd/ibd_segments.ibd |\
 java -Xmx12g -Xms12g -jar ${mergeibd} ${combinedvcf} ${map} 0.6 1 > merged_ibd_segments.ibd

#ne
cat merged_ibd_segments.ibd | java -jar ${ibdne} map=${map} out=${DIR}/ne nthreads=12
