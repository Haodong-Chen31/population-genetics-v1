#!/usr/bin/bash

#date: 24/11/05
#该代码基于HO,1240k两数据库计算了f4(Mbuti,tar;x1,x2)和f4(Mbuti,x1;tar,x2)
#filename of poplist: poplist_HO.txt poplist_1240k.txt
#usage: sh ~/code/f4/f4_1.sh [filename(path) HO] [filename(path) 1240k] [HO poplist] [1240k poplist] [target pop]

DIR=$(pwd)
fn_HO=$1
fn_1240k=$2
#读取参考人群，pop包含自己
popfn_HO=$3
popfn_1240k=$4
readarray -t tar < $5

# 删除以 = 开头的行
sed -i '/^=/d' ${popfn_HO}
sed -i '/^=/d' ${popfn_1240k}

f4() {
	local fn=$1
	local popfn=$2
	local num=$3
	readarray -t pop < ${popfn}
	panel=$(basename ${popfn} .txt | sed 's/^poplist_//')
	#make popfile
	for t in ${tar[@]};do
  		for ((i=0; i<${#pop[@]}; i++)); do
    			for ((j=0; j<${#pop[@]}; j++)); do
      				if [ ${num} = 2 ]; then
                			echo "Mbuti.DG ${t} ${pop[$i]} ${pop[$j]}"
                		elif [ ${num} = 3 ]; then
                    			echo "Mbuti.DG ${pop[$i]} ${t} ${pop[$j]}"
                		fi
    			done
  		done
	done > f4_${panel}_${num}.pop
	cat f4_${panel}_${num}.pop |\
	awk '$1 != $2 && $1 != $3 && $1 != $4 && $2 != $3 && $2 != $4 && $3 != $4' > tmp.pop
	rm f4_${panel}_${num}.pop; mv tmp.pop f4_${panel}_${num}.pop
	#f4
	cat > f4_${panel}_${num}.par << EOF
genotypename: ${fn}.geno
snpname:      ${fn}.snp
indivname:    ${fn}.ind
popfilename:  f4_${panel}_${num}.pop
f4mode:       YES
EOF
	qpDstat -p f4_${panel}_${num}.par > f4_${panel}_${num}.result
	grep result f4_${panel}_${num}.result |\
	awk '{print $3" "$4" "$7}' > f4_${panel}_${num}_z.txt
	grep result f4_${panel}_${num}.result |\
	awk '{print $2","$3","$4","$5","$6","$7","$8","$9","$10}' |\
	sed '1i\W,X,Y,Z,D-stat,z-score,BABA,ABBA,SNPs' > f4_${panel}_${num}.csv
}
f4 ${fn_HO} ${popfn_HO} 2
f4 ${fn_HO} ${popfn_HO} 3
f4 ${fn_1240k} ${popfn_1240k} 2
f4 ${fn_1240k} ${popfn_1240k} 3
