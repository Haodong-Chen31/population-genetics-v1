#!/bin/bash
#DIR=$(pwd)
awk 'NR==FNR{a[$2]=$1; next} {if ($1 in a) $1=a[$1]; if ($3 in a) $3=a[$3]; print}' ./data/ibd.fam ./3.merge_ibd/merged_ibd_segments.ibd > pop_ibd_segments.ibd
awk '$1==$3' pop_ibd_segments.ibd > within_pop_ibd_seg.ibd
cat ./data/ibd.fam | awk '{print $1}' | sort | uniq -c > ./data/pop_sample_num.txt
cat within_pop_ibd_seg.ibd | awk '{print $1}' | sort | uniq -c > ./data/pop_segment_num.txt
cat within_pop_ibd_seg.ibd | awk '{print $1,$3,$8,$9}' | awk '{sum3[$1" "$2] += $3; sum4[$1" "$2] += $4; count[$1" "$2]++} END {for (key in sum3) print key, sum3[key], sum4[key]}' > within_pop_score_length.txt
awk 'NR==FNR{a[$2]=$1; next} $1 in a{print $0, a[$1]}' ./data/pop_segment_num.txt within_pop_score_length.txt > within_pop_score_length_num.txt
awk '{print $0,$3/$5,$4/$5}' within_pop_score_length_num.txt > within_pop_score_length_num_ave.txt
awk 'NR==FNR{a[$2]=$1; next} $1 in a{print $0, a[$1]}' ./data/pop_sample_num.txt within_pop_score_length_num_ave.txt > within_pop_score_length_num_ave_sampnum.txt
awk '{print $0,$5/$8}' within_pop_score_length_num_ave_sampnum.txt > ./withinpop_result.txt
#一二列人群名，三LOD分数，四IBD片段长度，五片段数，六片段平均LOD score，七片段平均长度，八个体数，九平均每个体片段数
#画图七为横坐标，九为纵坐标
rm pop_ibd_segments.ibd within_pop_ibd_seg.ibd within_pop_score_length.txt within_pop_score_length_num.txt within_pop_score_length_num_ave.txt within_pop_score_length_num_ave_sampnum.txt
