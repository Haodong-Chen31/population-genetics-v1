library(pheatmap)
library(reshape2)
library(dplyr)
library(patchwork)

setwd('D:/R/Rworking/popgenetics/ganqing_0119/ibd')
a <- read.table('all_count_ave.txt',col.names = c('sample1','sample2','sum_score','sum_length',
                                             'nA','nB','ave_score','ave_length'))
popgroup <- read.table('popgroup.txt',sep = ',')
#a <- rbind(a, c(setdiff(a$sample2,a$sample1),setdiff(a$sample1,a$sample2),NA,NA,NA,NA,NA))
ibd_sum_score <- acast(a, sample1~sample2, value.var = "sum_score", drop = F)
ibd_sum_length <- acast(a, sample1~sample2, value.var = "sum_length", drop = F)
ibd_ave_score <- acast(a, sample1~sample2, value.var = "ave_score", drop = F)
ibd_ave_length <- acast(a, sample1~sample2, value.var = "ave_length", drop = F)

#上三角值给出，写入下三角
#ibd_sum_score[lower.tri(ibd_sum_score)] <- t(ibd_sum_score)[lower.tri(ibd_sum_score)]
#ibd_sum_length[lower.tri(ibd_sum_length)] <- t(ibd_sum_length)[lower.tri(ibd_sum_length)]
#ibd_ave_score[lower.tri(ibd_ave_score)] <- t(ibd_ave_score)[lower.tri(ibd_ave_score)]
#ibd_ave_length[lower.tri(ibd_ave_length)] <- t(ibd_ave_length)[lower.tri(ibd_ave_length)]

#转为对称矩阵
for (i in 1:nrow(ibd_sum_score)) {
  for (j in 1:ncol(ibd_sum_score)) {
    if (i==j) {
      ibd_sum_score[i,j] <- NA
    }
    if (is.na(ibd_sum_score[i,j])){
      ibd_sum_score[i,j] <- ibd_sum_score[j,i]
    }
  }
}

for (i in 1:nrow(ibd_sum_length)) {
  for (j in 1:ncol(ibd_sum_length)) {
    if (is.na(ibd_sum_length[i,j])){
      ibd_sum_length[i,j] <- ibd_sum_length[j,i]
    }
    if (i==j) {
      ibd_sum_length[i,j] <- NA
    }
  }
}

for (i in 1:nrow(ibd_ave_score)) {
  for (j in 1:ncol(ibd_ave_score)) {
    if (is.na(ibd_ave_score[i,j])){
      ibd_ave_score[i,j] <- ibd_ave_score[j,i]
    }
    if (i==j) {
      ibd_ave_score[i,j] <- NA
    }
  }
}

for (i in 1:nrow(ibd_ave_length)) {
  for (j in 1:ncol(ibd_ave_length)) {
    if (is.na(ibd_ave_length[i,j])){
      ibd_ave_length[i,j] <- ibd_ave_length[j,i]
    }
    if (i==j) {
      ibd_ave_length[i,j] <- NA
    }
  }
}


ibd_sum_score <- apply(ibd_sum_score, c(1,2), as.numeric)
ibd_sum_length <- apply(ibd_sum_length, c(1,2), as.numeric)
ibd_ave_score <- apply(ibd_ave_score, c(1,2), as.numeric)
ibd_ave_length <- apply(ibd_ave_length, c(1,2), as.numeric)

matrix_list <- list(ibd_sum_score,ibd_sum_length,ibd_ave_score,ibd_ave_length)
names(matrix_list) <- c('sum_of_LOD_score','sum_of_length','mean_LOD_socre','mean_length')

annotation_row <- data.frame(group=popgroup$V2)
rownames(annotation_row) <- popgroup$V1
annotation_col <- annotation_row
ann_colors=list(group=c(Target='#F57C7C',Mongolian='#0080FF',Tibetan='#FBB268',Turkic='#BCF60C',
                        Austronesian='#F032E6',Hmong='#00FA9A',Europe='#B15928',Han_Chinese='#9D7BBA'))
for (i in 1:4) {
  ht <- pheatmap(matrix_list[[i]], main = gsub('_',' ',paste0('The ', names(matrix_list)[i], 
                                                              ' of IBD segments shared between individuals in both populations')),
                 color = colorRampPalette(c("white", "#A6CEE3"),alpha = 0.1)(60),
                 cellwidth = 10,cellheight = 10,
                 cutree_cols = 3, cutree_rows = 3,
                 annotation_row = annotation_row, annotation_col = annotation_col,
                 annotation_colors = ann_colors,
                 breaks = seq(0, 20, length.out = 61),
                 legend_breaks = c(0, 5, 10, 15, 20),      # 图例显示的刻度
                 legend_labels = c("0","5","10","15","20+")
  )
  pdf_name <- paste(names(matrix_list)[i],'.pdf',sep = '')
  pdf(pdf_name,width =10,height =9)
  print(ht)
  dev.off()
}

# The mean LOD score of IBD segments shared between individuals in both populations
# The mean length of IBD segments shared between individuals in both populations
# The sum of LOD score of IBD segments shared between individuals in both populations
# The sum of length of IBD segments shared between individuals in both populations