#!/usr/bin/sh

#usage: sh ~/code/fst/extract_fst.sh [merged file name(path)] [poplist for fst]

DIR=$(pwd)
fn=$1
POP_NAME=$2

#extract pop
PARAMSFILE=${DIR}/parextract
cat<<EOF>${PARAMSFILE}
genotypename:	${fn}.geno
snpname:	${fn}.snp
indivname:	${fn}.ind
outputformat:	EIGENSTRAT
genooutfilename:	${DIR}/fst.geno
snpoutfilename:		${DIR}/fst.snp
indoutfilename:		${DIR}/fst.ind
poplistname:	${DIR}/${POP_NAME}
hashcheck:	NO
strandcheck:	NO
allowdups:	YES
EOF

convertf -p $PARAMSFILE

#fst
PAR_FST=${DIR}/parfst
cat<<EOF>${PAR_FST}
genotypename:	${DIR}/fst.geno
snpname:	${DIR}/fst.snp
indivname:	${DIR}/fst.ind
poplistname:	${DIR}/${POP_NAME}
inbreed:	YES
phylipoutname:	${DIR}/result_fst
fstonly:	YES
EOF

smartpca -p ${PAR_FST}

cat result_fst | sed '1d' | sed 's/-/ -/g' | sed 's/ -[^ ]*/ 0/g' > result_fst_for_r
cat ${POP_NAME} | paste - result_fst_for_r | awk '{$2="";print $0}' > result_fst_for_r2
rm result_fst_for_r;mv result_fst_for_r2 result_fst_for_r
sed -i 's/[ ][ ]*/ /g' result_fst_for_r

#for phylip
#num=$(wc -l ${POP_NAME} | awk '{print $1}')
#sed '1i\ ' poplist.txt > poplist_num.txt
#cat poplist_num.txt | paste - result_fst | awk '{$2="";print $0}' > infile
#cat infile | sed 's/-/ -/g' | sed 's/ -[^ ]*/ 0/g' > infile2
#rm infile;mv infile2 infile
