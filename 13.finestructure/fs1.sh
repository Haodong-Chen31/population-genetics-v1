#======================whole haplotype-based analysis process=====================
OUTDIR=/home/HuangzhenHuang/analysis/Projects/Guizhou/14.fs
################################################################################################
#data preparation
mkdir $OUTDIR/data
HODIR=/home/HuangzhenHuang/data/Guizhou/Merge/merge_Guizhou_HO_ind/newname
Fn_HO=$HODIR/finaldata_Guizhou_HO.v02

Fn_fs=$OUTDIR/data/fs
fs_poplist=$OUTDIR/fs.poplist
###########################
PARAMSFILE=${OUTDIR}/data/extract.par
printf "genotypename:\t${Fn_HO}.geno\n" > $PARAMSFILE
printf "snpname:\t${Fn_HO}.snp\n" >> $PARAMSFILE
printf "indivname:\t${Fn_HO}.ind\n" >> $PARAMSFILE
printf "outputformat:\tEIGENSTRAT\n" >> $PARAMSFILE
printf "genooutfilename:\t${Fn_fs}.geno\n" >> $PARAMSFILE
printf "snpoutfilename:\t${Fn_fs}.snp\n" >> $PARAMSFILE
printf "indoutfilename:\t${Fn_fs}.ind\n" >> $PARAMSFILE
printf "poplistname:\t${fs_poplist}\n" >> $PARAMSFILE
printf "hashcheck:\tNO\n" >> $PARAMSFILE
printf "strandcheck:\tNO\n" >> $PARAMSFILE
printf "allowdups:\tYES\n" >> $PARAMSFILE
convertf -p $PARAMSFILE && echo 'extract,Well Done!'
###########################
#convert into bfile
PARAMSFILE1=${OUTDIR}/data/convertf.par
printf "genotypename:\t${Fn_fs}.geno\n" > $PARAMSFILE1
printf "snpname:\t${Fn_fs}.snp\n" >> $PARAMSFILE1
printf "indivname:\t${Fn_fs}.ind\n" >> $PARAMSFILE1
printf "outputformat:\tPACKEDPED\n" >> $PARAMSFILE1
printf "genooutfilename:\t${Fn_fs}.bed\n" >> $PARAMSFILE1
printf "snpoutfilename:\t${Fn_fs}.bim\n" >> $PARAMSFILE1
printf "indoutfilename:\t${Fn_fs}.fam\n" >> $PARAMSFILE1
printf "hashcheck:\tNO\n" >> $PARAMSFILE1
printf "strandcheck:\tNO\n" >> $PARAMSFILE1
printf "allowdups:\tYES\n" >> $PARAMSFILE1
convertf -p $PARAMSFILE1
#改fam文件
awk -F " " 'NR==FNR{pop[$1]=$3}NR>FNR{print pop[$2],substr($0,index($0,$2))}' ${Fn_fs}.ind ${Fn_fs}.fam > ${Fn_fs}_1.fam
rm ${Fn_fs}.fam
mv ${Fn_fs}_1.fam ${Fn_fs}.fam
###########################
#3==========保证每个群体没有超过10个样本==========
#如果样本数>10,取前10个(head)
# 如果样本数<=10,保留全部
#一般来说,FineSTRUCTURE建议每个群体样本数在10以内。
OUTDIR=/home/HuangzhenHuang/analysis/Projects/Guizhou/14.fs
cd $OUTDIR/data

idlist=fs.idlist
rm $idlist
touch $idlist

for i in `cat fs.fam | awk -F " " '{print $1}' | sort | uniq`;do
    sample_count=`cat fs.fam | grep ${i} | wc -l`
    echo ${i}_${sample_count}
    if [ ${sample_count} -gt 10 ];then
        cat fs.fam | grep -w ${i} | awk -F " " '{print $1,$2}' | head -n 10 >> $idlist
    else
        cat fs.fam | grep -w ${i} | awk -F " " '{print $1,$2}' >> $idlist
    fi
done    
plink --bfile fs --keep $idlist --make-bed --out fs10
################################################################################################

#质控
plink --bfile $OUTDIR/data/fs10 --me 1 1 --set-me-missing --keep-allele-order --geno 0.05 --mind 0.10 --make-bed --out $OUTDIR/data/fs10_qc
#按染色体分别提取1-22
mkdir $OUTDIR/data/chr
for x in {1..22}; do
    plink --bfile $OUTDIR/data/fs10_qc --chr $x --make-bed --alleleACGT --out $OUTDIR/data/chr/fs10_qc.chr$x; done

################################################################################################
#phase
mkdir $OUTDIR/phase

for x in {1..22}; do 
    shapeit --duohmm -W 5 --thread 20 \
    --input-bed $OUTDIR/data/chr/fs10_qc.chr$x.bed $OUTDIR/data/chr/fs10_qc.chr$x.bim $OUTDIR/data/chr/fs10_qc.chr$x.fam \
    --input-map /home/HuangzhenHuang/map/genetic_map_GRCh37_chr${x}_final.txt \
    -O $OUTDIR/phase/data_phased.chr$x > $OUTDIR/phase/chr$x.log 
done

################################################################################################

################################################################################################
OUTDIR=/home/HuangzhenHuang/analysis/Projects/Guizhou/14.fs
mkdir $OUTDIR/input
#生成.phase文件
for x in {1..22}; do 
    impute2chromopainter.pl $OUTDIR/phase/data_phased.chr$x.haps $OUTDIR/input/data.chr$x ; done
#生成recombfile文件
for x in {1..22}; do 
    convertrecfile.pl -M hap $OUTDIR/input/data.chr$x.phase /home/HuangzhenHuang/map/genetic_map_GRCh37_chr${x}.txt $OUTDIR/input/data.chr$x.recombfile; done
#生成id文件
cat -n $OUTDIR/data/chr/fs10_qc.chr1.fam | awk -F " " '{print $2"_"$1,$2,1}'  > $OUTDIR/input/data.ids
################################################################################################