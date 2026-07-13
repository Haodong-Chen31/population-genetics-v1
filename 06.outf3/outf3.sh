#!/usr/bin/bash

#date: 24/11/05
#usage: sh outf3.sh [merged filename(path) HO] [merged filename(path) 1240k] [poplist HO] [poplist 1240k] [target pop]

DIR=$(pwd)
fn=$1
#准备两poplist人群，其不含研究人群及外群
poplist=$2
panel=$3
#目标人群的poplist
readarray -t tar < $4

> outf3_${panel}.pop
for t in ${tar[@]};do
        cat ${poplist} | sed '/./{s/^/'${t}' /g;s/$/ Mbuti.DG/g}' >> outf3_${panel}.pop
done
cat outf3_${panel}.pop | \
awk '$1 != $2 && $1 != $3 && $2 != $3' > tmp.pop
rm outf3_${panel}.pop; mv tmp.pop outf3_${panel}.pop

outf3() {
	local fn=$1
	local pan=$2
	cat >outf3_${pan}.par<<EOF
genotypename:   ${fn}.geno
snpname:        ${fn}.snp
indivname:      ${fn}.ind
popfilename:    ${DIR}/outf3_${pan}.pop
inbreed:        YES
EOF
	qp3Pop -p outf3_${pan}.par > outf3_${pan}.result
	grep result outf3_${pan}.result | awk '{$1="";print $0}'| \
	sed 's/[ ][ ]*/ /g' | sed 's/^[ \t]*//g' | \
	sort -k 4 -nr | sed '1i\source_1 source_2 target f_3 std.err z snps'| \
	sed 's/ /,/g' > outf3_${pan}.sort.csv
	grep result outf3_${pan}.result | awk '{$1="";print $0}'| \
	sed 's/[ ][ ]*/ /g' | sed 's/^[ \t]*//g' | \
	sed '1i\source_1 source_2 target f_3 std.err z snps'| \
	sed 's/ /,/g' > outf3_${pan}.r.csv
}
outf3 ${fn} ${panel}
