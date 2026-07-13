#!/bin/usr/bash

cat ./data/ibd.fam | awk '{print $1}' | sort | uniq -c > ./data/pop_sample_num.txt

awk 'NR==FNR{a[$2]=$1; next} {if ($1 in a) $1=a[$1]; if ($3 in a) $3=a[$3]; print}' ./data/ibd.fam ./3.merge_ibd/merged_ibd_segments.ibd |\
awk '{print $1,$3,$8,$9}' |\
awk '{sum3[$1" "$2] += $3; sum4[$1" "$2] += $4; count[$1" "$2]++} END {for (key in sum3) print key, sum3[key], sum4[key]}' > all.txt

Rscript /home/HaodongChen/code/ibd/sub.R all.txt

cat all2.txt | awk '{sum3[$1" "$2] += $3; sum4[$1" "$2] += $4; count[$1" "$2]++} END {for (key in sum3) print key, sum3[key], sum4[key]}' > all.txt

awk 'NR==FNR{a[$2]=$1; next} $1 in a{print $0, a[$1], a[$2]}' ./data/pop_sample_num.txt all.txt > all_count.txt

awk '{print $1,$2,$3,$4,$5,$6,$3/$5/$6,$4/$5/$6}' all_count.txt > all_count_ave.txt

rm all.txt all2.txt all_count.txt
