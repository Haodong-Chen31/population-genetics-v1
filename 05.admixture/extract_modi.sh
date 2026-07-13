#!/bin/bash
#usage: sh extract_modi.sh [merge file name(path)] [target directory(path)] [poplist for admixture] [files for admixture]
DIR=$(pwd)
OUTDIR=${DIR}/result
fn=$1
POP=$2
#school_dir=$3
FILENAME=admixture

mkdir -p ${OUTDIR}
##extract
cat<<EOF>parextract
genotypename:	${fn}.geno
snpname:	${fn}.snp
indivname:	${fn}.ind
outputformat:	EIGENSTRAT
genooutfilename:	${DIR}/${FILENAME}.geno
snpoutfilename:	${DIR}/${FILENAME}.snp
indoutfilename:	${DIR}/${FILENAME}.ind
poplistname:	${DIR}/${POP}
hashcheck:	NO
strandcheck:	NO
allowdups:	YES
EOF
convertf -p parextract

##convert
cat<<EOF>parconvertf
genotypename:	${DIR}/${FILENAME}.geno
snpname:	${DIR}/${FILENAME}.snp
indivname:	${DIR}/${FILENAME}.ind
outputformat:	PACKEDPED
genooutfilename:	${DIR}/${FILENAME}.bed
snpoutfilename:	${DIR}/${FILENAME}.bim
indoutfilename:	${DIR}/${FILENAME}.fam
EOF
convertf -p parconvertf

##修改.fam文件
cat ${DIR}/${FILENAME}.ind > ${DIR}/1.txt
printf "\n" >> ${DIR}/1.txt;cat ${FILENAME}.ind >> ${DIR}/1.txt
awk -F " " 'NR==FNR{pop[$1]=$3}NR>FNR{print pop[$2],substr($0,index($0,$2))}' 1.txt ${FILENAME}.fam > ${FILENAME}_1.fam
rm ${FILENAME}.fam ${DIR}/1.txt
mv ${FILENAME}_1.fam ${FILENAME}.fam

plink --bfile ${DIR}/${FILENAME} --indep-pairwise 200 25 0.4 --out ${DIR}/${FILENAME}
plink --bfile ${DIR}/${FILENAME} --extract $DIR/${FILENAME}.prune.in --make-bed --out ${DIR}/${FILENAME}_LD_prune

# ADMIXTURE
degree=4
for i in `seq 2 12`
do
    nohup admixture -j5 --cv=10 ${DIR}/${FILENAME}.bed ${i} | tee ${OUTDIR}/admix${i}.log & # 提交到后台的任务
    echo $i
    [ `expr $i % $degree` -eq 0 ] && wait
done

mv *.P *.Q result/
cp ${DIR}/${FILENAME}.fam /home/HaodongChen/code/admixture/command.r /home/HaodongChen/code/admixture/cverror_line.R ${OUTDIR}
grep -h CV ${OUTDIR}/admix*.log | sed 's/(K=//' | sed 's/)://' > ${OUTDIR}/cv_error.txt
Rscript ${OUTDIR}/cverror_line.R ${OUTDIR}/cv_error.txt

# awk 'NR==FNR {id[NR]=$1"\t"$2; next} {print id[FNR]"\t"$0}' admixture.fam admixture.5.Q > admixture_with_sample.5.Q.txt
