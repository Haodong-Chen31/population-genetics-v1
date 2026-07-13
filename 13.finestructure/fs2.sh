#!/bin/bash

#======================whole haplotype-based analysis process=====================
OUTDIR=/home/HuangzhenHuang/analysis/Projects/Guizhou/14.fs
################################################################################################
mkdir $OUTDIR/result
cd $OUTDIR/result

#hpc mode

fs fs.cp -hpc 1 -idfile $OUTDIR/input/data.ids -phasefiles $OUTDIR/input/data.chr{1..22}.phase -recombfiles $OUTDIR/input/data.chr{1..22}.recombfile -s3iters 100000 -s4iters 50000 -s1minsnps 1000 -s1indfrac 0.1 -go
date > commandfile1.time
cat fs/commandfiles/commandfile1.txt | parallel --jobs 20
fs fs.cp -go
date >> commandfile1.time

date > commandfile2.time
cat fs/commandfiles/commandfile2.txt | parallel --jobs 20
fs fs.cp -go
date >> commandfile2.time

date > commandfile3.time
cat fs/commandfiles/commandfile3.txt | parallel --jobs 20
fs fs.cp -go
date >> commandfile3.time


date > commandfile4.time
cat fs/commandfiles/commandfile4.txt | parallel --jobs 20
fs fs.cp -go
date >> commandfile4.time


