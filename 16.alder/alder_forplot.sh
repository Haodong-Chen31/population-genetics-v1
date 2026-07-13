#!/bin/sh

dir=$(pwd)
readarray -t targets < target.txt

mkdir -p plot
find ./result -type f -print0 |\
xargs -0 grep "success" |\
sed 's/ (warning: decay rates inconsistent)/(warning)/g' > success.txt
echo -e "target\trefA\trefB\tp-value\tz-score\tdecay\tstd_decay\tamp_exp\tamp_aff" > plot/parameter_alderplot.txt

for t in ${targets[@]};do
	#得到按照Z值降序排列的结果
	cat success.txt | grep ${t} | sort -k7,7 -r > ${t}
	fn_zmax=$(head -n1 ${t} | awk '{print $1}' | sed 's/\.log:DATA:// ; s/^\.\/result\///')
	if [ -z ${fn_zmax} ]; then
        continue
	fi
	#parameter file for plot
	p_value=$(head -n1 ${t} | awk '{print $3}')
	target=$(head -n1 ${t} | awk '{print $4}')
	refA=$(head -n1 ${t} | awk '{print $5}')
	refB=$(head -n1 ${t} | awk '{print $6}')
	z_score=$(head -n1 ${t} | awk '{print $7}')
	decay=$(head -n1 ${t} | awk '{print $11}')
	std_decay=$(head -n1 ${t} | awk '{print $13}')
	amp_exp=$(head -n1 ${t} | awk '{print $14}')
	amp_aff=$(cat result/${fn_zmax}.log | grep amp_aff | head -n1 | awk '{print $3}')
	echo -e "${target}\t${refA}\t${refB}\t${p_value}\t${z_score}\t${decay}\t${std_decay}\t${amp_exp}\t${amp_aff}" >> plot/parameter_alderplot.txt
	#result file for plot
	cp result/${fn_zmax}.log result/${fn_zmax}.result plot/
	echo -e 'Dist\tweightedLD\tnpairs\tuse' > plot/alderplot_${fn_zmax}.txt
	head -n -2 plot/${fn_zmax}.result | tail -n +2 | awk '{OFS="\t"} {if ($1 == "#") print $2,$3,$4,"N"; else print $1,$2,$3,"Y"}' >> plot/alderplot_${fn_zmax}.txt
done &&

cp alder_plot.r plot/ ; cd plot/
Rscript alder_plot.r

