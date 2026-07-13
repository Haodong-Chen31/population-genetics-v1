#!/bin/sh

DIR=$(pwd)
fn=$1
poplist=$2

#extract
PARFILE=${DIR}/parextract
cat<<EOF>${PARFILE}
genotypename:   ${fn}.geno
snpname:        ${fn}.snp
indivname:      ${fn}.ind
outputformat:   EIGENSTRAT
genooutfilename:        ${DIR}/roh.geno
snpoutfilename: ${DIR}/roh.snp
indoutfilename: ${DIR}/roh.ind
poplistname:    ${DIR}/${poplist}
hashcheck:      NO
strandcheck:    NO
allowdups:      YES
EOF
convertf -p ${PARFILE}

#convert eigen2plink
PARFILE=${DIR}/parconvert_eigen2plink
cat<<EOF>${PARFILE}
genotypename:   ${DIR}/roh.geno
snpname:        ${DIR}/roh.snp
indivname:      ${DIR}/roh.ind
outputformat:   PACKEDPED
genooutfilename:        ${DIR}/roh.bed
snpoutfilename: ${DIR}/roh.bim
indoutfilename: ${DIR}/roh.fam
EOF
convertf -p ${PARFILE}

#.fam文件改对
cat ${DIR}/roh.ind > ${DIR}/1.txt
printf "\n" >> ${DIR}/1.txt;cat ${DIR}/roh.ind >> ${DIR}/1.txt
awk -F " " 'NR==FNR{pop[$1]=$3}NR>FNR{print pop[$2],substr($0,index($0,$2))}' ${DIR}/1.txt ${DIR}/roh.fam > ${DIR}/roh_1.fam
rm ${DIR}/roh.fam ${DIR}/1.txt
mv ${DIR}/roh_1.fam ${DIR}/roh.fam

#plink算ROH
plink \
--bfile roh \
--homozyg \
--homozyg-density 50 \
--homozyg-gap 100 \
--homozyg-kb 500 \
--homozyg-snp 50 \
--homozyg-window-het 1 \
--homozyg-window-snp 50 \
--homozyg-window-threshold 0.05 \
--out roh
