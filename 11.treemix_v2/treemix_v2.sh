#!/bin/sh

workdir=$(pwd)
mkdir log
#ncore--parallel nboot--无migration骨架树 生成共识树 migrep--每个-m的重复
sh Step1_TreeMix.sh treemix.frq.gz 10 500 Mbuti.DG 10 /home/HaodongChen/software/phylip-3.697/exe/consense treemix 0 3 10 > log/step1.log

exit

# step 2: 确定最优m
# 参数2先随便定义一个，暂时用不到，第四步才用得到。
# 参数3也是
Rscript Step2\&4_TreeMix.R ${workdir} 1 1
mv Rplots.pdf optimal_number_of_migration.pdf

# 第5个参数nboot：算 migration / tree 的支持度，用到了step1生成的共识树treemix_constree.newick，生成共识树treemix_finalconstree.newick（带m）
# 第6个参数为确定的最优m
# 第8个参数runs：选最终 ML tree + migration
sh Step3_TreeMix.sh treemix.frq.gz 10 500 Mbuti.DG 10 3 treemix 10 treemix_constree.newick /home/HaodongChen/software/phylip-3.697/exe/consense > log/step3.log

#准备画图的文件，已有poplist文件
awk '{print $0 "\t#000000"}' poplist_HO.txt > final_runs/col.txt
cp final_runs/col.txt final_runs/poporder.txt

# step 4: 参数2为确定的最优m
# 最终在final_runs文件夹下生成了共识树Consensus.newick
# 参数2为最优的m，画确定的m下，多次重复中，likelihood最高的树
# 参数3为runs次数，对应Step3_TreeMix.sh的参数8
Rscript Step2\&4_TreeMix.R ${workdir} 3 10
