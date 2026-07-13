#只需改行4函数f..的第一个参数，如文件夹Admixture plot下的.Q文件，只需改前面的名字
#！注意！.Q文件和.fam文件名字要一样！
#进入admixture结果文件夹下
args = commandArgs(trailingOnly = TRUE)
#.Q文件前缀
fn <- args[1]
kmin <- as.numeric(args[2])
kmax <- as.numeric(args[3])

if (as.numeric(kmin) == as.numeric(kmax)) {
  output_fn <- paste0(fn, "_k", kmin)
} else {
  output_fn <- paste0(fn, "_k", kmin, "to", kmax)
}

source("/home/HaodongChen/code/admixture/fancyADMIXTURE.r")
source("/home/HaodongChen/code/admixture/averagePopsUnsorted.r")
fancyADMIXTURE(fn, KMIN=kmin, KMAX=kmax, HCLUST=F, PNG=F, OUTFILEPREFIX=output_fn)
