#!/bin/sh

for an in anc1; do
# 	#sh extract.sh ../data/1240k.v04_ganqing ${an} ${an}
# 	#sh convert_eigen2plink.sh ${an}
# 	# 质控 并去除摩尔根位置相同的位点
# 	#plink --bfile ${an} --geno 0 --make-bed --out ${an}_qc
# 	awk '
# 	{
# 	    key = $1 "_" $3
# 	    if (!(key in seen)) {
# 	        seen[key] = NR
# 	        line[NR] = $0
# 	    } else {
# 	        # 随机决定是否替换
# 	        if (rand() < 0.5) {
# 	            removed[seen[key]] = line[seen[key]]
# 	            seen[key] = NR
# 	            line[NR] = $0
# 	        } else {
# 	            removed[NR] = $0
# 	        }
# 	    }
# 	}
# 	END {
# 	    for (i in seen) print line[seen[i]] > "dedup.bim"
# 	    for (i in removed) print removed[i] > "removed.bim"
# 	}
# 	' ${an}_qc.bim
# 	awk '{print $2}' removed.bim > removed.snps
# 	plink --bfile ${an}_qc --exclude removed.snps --make-bed --out ${an}_qc_rmsnp
# 	rm dedup.bim removed.bim
	for chr in {1..23}; do
		plink --bfile ${an}_qc_rmsnp --recode vcf-iid --chr ${chr} --out ${an}_qc_rmsnp_chr${chr}
		if [[ ${chr} -eq 23 ]]; then
			python /home/HaodongChen/software/AdmixSim2/other_scripts/vcf2hap.py --input ${an}_qc_rmsnp_chr${chr} --chr X --out ${an}_qc_rmsnp_chr${chr}
		else
			python /home/HaodongChen/software/AdmixSim2/other_scripts/vcf2hap.py --input ${an}_qc_rmsnp_chr${chr} --chr ${chr} --out ${an}_qc_rmsnp_chr${chr}
		fi
		# 编辑snv文件
		cat ${an}_qc_rmsnp.bim | awk -v c="${chr}" '$1==c {print $4,$3,"-9"}' OFS='\t' > ${an}_qc_rmsnp_chr${chr}.snv
		# 编辑mod文件 基于alder qpadm结果去模拟
		# 编辑ind文件
		cat ${an}_qc_rmsnp.fam | awk '{print $2,$1,"0"}' OFS='\t' > ${an}_qc_rmsnp_chr${chr}.ind
	done
done

cat >anc1_qc_rmsnp.mod<<EOF
*1-30	Han.DG,GBR.SG,Admixed
100	0.5,0.5,0
100	0.5,0,0.5
100	0.5,0,0.5
100	0.5,0,0.5
100	0.5,0,0.5
100	0.5,0,0.5
100	0.5,0,0.5
100	0.5,0,0.5
100	0.5,0,0.5
100	0.5,0,0.5
100	0.5,0,0.5
100	0.5,0,0.5
100	0.5,0,0.5
100	0.5,0,0.5
100	0.5,0,0.5
100	0.5,0,0.5
100	0.5,0,0.5
100	0.5,0,0.5
100	0.5,0,0.5
100	0.5,0,0.5
100	0.5,0,0.5
100	0.5,0,0.5
100	0.5,0,0.5
100	0.5,0,0.5
100	0.5,0,0.5
100	0.5,0,0.5
100	0.5,0,0.5
100	0.5,0,0.5
100	0.5,0,0.5
100	0.5,0,0.5
EOF


# 编辑mod文件 基于alder qpadm结果去模拟
for an in anc1; do
	for chr in {1..23}; do
		cp ${an}_qc_rmsnp.mod ${an}_qc_rmsnp_chr${chr}.mod
	done
done

# AdmixSim2
#python /home/HaodongChen/software/AdmixSim2/src_python/AdmixSim2.py --hap anc1_qc_rmsnp_chr1.hap --mod anc1_qc_rmsnp_chr1.mod --snv anc1_qc_rmsnp_chr1.snv --ind anc1_qc_rmsnp_chr1.ind -o t -p Admixed -g 30 -n 4 --mut-rate 0.00000001
#AdmixSim2 -in anc1_qc_rmsnp_chr1 -p Admixed -g 30 -n 100 -mut 0.00000001 -out t2
> multiwaver.parl
for an in anc1; do
	for chr in {1..22}; do
		AdmixSim2 -in ${an}_qc_rmsnp_chr${chr} -p Admixed -g 30 -n 100 -mut 0.00000001 -out ${an}_qc_rmsnp_chr${chr}_admixsim2
	done
	# 合并所有常染色体上的片段 100个个体
	cat ${an}_qc_rmsnp_chr*_admixsim2.seg | grep -v '^Ind' | awk '{print $2,$4,$5}' OFS='\t' > ${an}_qc_rmsnp.seg
	# MultiWaver v2.0
	echo "MultiWaveInfer2 -i ${an}_qc_rmsnp.seg -o ${an}_qc_rmsnp.multiwaver.txt -g ${an}_qc_rmsnp.multiwaver.log -b 100" >> multiwaver.parl
done
cat multiwaver.parl | parallel -j 1
