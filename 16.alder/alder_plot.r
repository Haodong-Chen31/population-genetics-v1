result_files <- list.files(pattern = "^alderplot")
para <- read.table("parameter_alderplot.txt",header = T)

for (i in 1:nrow(para)) {
  n <- para$decay[i]       ## decay parameter
  M <- para$amp_exp[i]  ## amp_exp
  K <- para$amp_aff[i]   ## amp_aff
  
  d1 <- read.table(paste0("alderplot_",para$target[i],"-",para$refA[i],"-",para$refB[i],".txt"), header=T)
  xv <- as.vector(d1$Dist)        ## distance between SNP bins (cM)
  yv <- as.vector(d1$weightedLD)  ## Weighted LD
  fv <- as.vector(d1$use) == "Y"  ## a boolean vector marking if each bin is used in fitting
  prdv <- M * exp(-1 * n * xv / 100) + K
  
  pdf(paste0(para$target[i],"-",para$refA[i],"-",para$refB[i],".pdf"),width =8,height =6.6)
  plot(xv[fv], yv[fv], xlab="Genetic distance (cM)", ylab = paste0("weighted LD (",para$target[i],"; 2-ref)"), pch=4, col="#0080FF")
  points(xv[fv], prdv[fv], type="l", lwd=1.5, col="#FF0000")
  # 添加图例
  legend("topright",
         legend = c(paste0(para$refA[i],"-",para$refB[i]," weights"), paste0("Exp fit: ",para$decay[i]," +/- ",para$std_decay[i])),
         col = c("#0080FF", "#FF0000"),
         pch = c(4, NA),  # NA for no point symbol on the line legend
         lty = c(NA, 1))  # NA for no line type on the point legend
  dev.off()
}
