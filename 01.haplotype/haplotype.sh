#!/usr/bin

fn=$1

rm -r haplogrep yhaplo yhaplo_flipped ylineagetracker

#extract male
plink --bfile ${fn} --check-sex --make-bed
cat plink.sexcheck | awk '$4==1{print $1,$2}' > male.txt
plink --bfile ${fn} --keep male.txt --make-bed --out male

#y
plink --bfile male --chr 24 --make-bed --out y
plink --bfile y --recode vcf --out y
cat y.vcf | sed 's/^24/Y/g; s/ID=24/ID=Y/g' > chrY.vcf
#检测和修正VCF文件中与参考基因组不一致的位点
bcftools +fixref chrY.vcf -Ov -o y.flipped.vcf -- -f /home/HaodongChen/ref/hs37d5_Y.fa -m flip -d > flip_Y.log 2>&1

#mt
plink --bfile ${fn} --chr 26 --make-bed --out mt
plink --bfile mt --recode vcf --out mt
cat mt.vcf | sed 's/^26/MT/g; s/ID=26/ID=MT/g' > chrMT.vcf
#检测和修正VCF文件中与参考基因组不一致的位点
bcftools +fixref chrMT.vcf -Ov -o mt.flipped.vcf -- -f /home/administrator/data/Reference_Genomes/Human/hs37d5_MT.fa -m flip -d > flip_MT.log 2>&1

##yhaplo
python -m yhaplo.call_haplogroups -i y.flipped.vcf -o yhaplo_flipped
python -m yhaplo.call_haplogroups -i y.vcf -o yhaplo

##y-lineageTracker
mkdir ylineagetracker
LineageTracker classify --vcf y.vcf -b 37 -o ylineagetracker/y
LineageTracker phylo --hg ylineagetracker/y.hapresult.hg -o ylineagetracker/y

LineageTracker classify --vcf y.flipped.vcf -b 37 -o ylineagetracker/y_flipped
LineageTracker phylo --hg ylineagetracker/y_flipped.hapresult.hg -o ylineagetracker/y_flipped

##haplogrep
mkdir haplogrep
haplogrep classify --in mt.vcf --format vcf --out haplogrep/mt.haplo.out
haplogrep classify --in mt.flipped.vcf --format vcf --out haplogrep/mt_flipped.haplo.out

#结果整理
#awk '{split($1, a, "_"); print a[3]"_"a[4]"\t"$4}' yhaplo/haplogroups.y.txt > tmp1.txt
cat yhaplo/haplogroups.y.txt | sort -k1,1 | awk '{print $1,$4}' > tmp1.txt
awk '{print $4}' yhaplo_flipped/haplogroups.y.flipped.txt > tmp2.txt
tail -n +2 ylineagetracker/y.hapresult.hg | sort -k1,1 | awk '{print $2}'
awk 'NR>=2{print $2}' ylineagetracker/y.hapresult.hg | sort -k1 > tmp3.txt
tail -n +2 ylineagetracker/y_flipped.hapresult.hg | sort -k1,1 | awk '{print $2}'
awk 'NR>=2{print $2}' ylineagetracker/y_flipped.hapresult.hg | sort -k1 > tmp4.txt
awk 'NR>=2{print $2}' haplogrep/mt.haplo.out | sed s/\"//g > tmp5.txt
awk 'NR>=2{print $2}' haplogrep/mt_flipped.haplo.out | sed s/\"//g > tmp6.txt
echo -e "sampleID\tYhaplo\tYhaplo_flipped\tY-LineageTracker\tY-LineageTracker_flipped\thaplogrep2\thaplogrep2_flipped" > haplotype.out
paste -d "\t" tmp1.txt tmp2.txt tmp3.txt tmp4.txt tmp5.txt tmp6.txt >> haplotype.out
rm tmp*

#less final.result | awk '{print substr($0, 1, 1)}' | sort | uniq -c | awk '{print $2","$1}'
