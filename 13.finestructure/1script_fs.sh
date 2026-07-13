#!/bin/sh
export PATH="/home/rw/sotware/fs_4.1.1:$PATH"
#========================FINESTRUCTURE=====================================
#==========FINESTRUCTURE run==========
INDIR=${PWD}
OUTDIR=${PWD}
final_filename=${OUTDIR}/present_day_East_Asians_target_QC

# fs的输入文件
#==========生成idfile文件==========
# 1：代表include；0：代表exclude
# 因为fs不支持很长的indid名，所以我把所有的indid都改成pop_行数了
cat -n ${final_filename}.fam | awk -F " " '{print $2"_"$1,$2,1}' > ${final_filename}_fs.ids

rm -rf fs
fs fs.cp -hpc 1 -idfile ${final_filename}_fs.ids -phasefiles ${final_filename}.chr{1..22}.phase -recombfiles ${final_filename}.chr{1..22}.recombfile -s3iters 100000 -s4iters 50000 -s1minsnps 1000 -s1indfrac 0.1 -go

cd ${OUTDIR}
cat fs/commandfiles/commandfile1.txt | parallel
# Failed to read fs/stage2/fs_tmp_mainrun.linked_file1_ind1.chunkcounts.out in stage -combines2. This is usually because -dos2 has not been performed 应该不用管
fs fs.cp -go
cat fs/commandfiles/commandfile2.txt | parallel
fs fs.cp -go
cat fs/commandfiles/commandfile3.txt | parallel
fs fs.cp -go
cat fs/commandfiles/commandfile4.txt | parallel
fs fs.cp -go

export PATH="/usr/bin:$PATH"
# 画图 一定要保证画图的两个R文件和fs在同一个文件夹下！！否则会报错说找不到Fine.R文件
cp /home/RuiWang/Tibetan_script/Fine* ./
# 用RuiWang账号运行就行
Rscript Finestructure16.R.template ./ fs
