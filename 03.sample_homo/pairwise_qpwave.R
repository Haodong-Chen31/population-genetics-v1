library(reshape2)
library(pheatmap)
library(tools)

setwd('E:/Rworking/popgenetics/ganqing_0119/sample_homo/')

qp_value <- "tail.txt"
pop <- "poplist.txt"
qpwave_p <- read.table(qp_value,header = F)
poplist <- read.table(pop)
# 加上poplist自由组合第一个和最后一个元素
qpwave_p <- rbind(qpwave_p,c(poplist[1,1],poplist[1,1],NA))
qpwave_p <- rbind(qpwave_p,c(poplist[dim(poplist)[1],1],poplist[dim(poplist)[1],1],NA))
# 转长格式为宽格式
qpwave_matrix <- acast(qpwave_p, V1~V2, value.var="V3", drop = F)


# 转为对称矩阵
for (i in 1:nrow(qpwave_matrix)) {
  for (j in 1:ncol(qpwave_matrix)) {
    if (is.na(qpwave_matrix[i,j])){
      qpwave_matrix[i,j] <- qpwave_matrix[j,i]
    }
  }
}
# 将矩阵所有元素转为数字类型
qpwave_matrix <- apply(qpwave_matrix, c(1,2), as.numeric)

annotation <- matrix(ifelse(qpwave_matrix > 0.05, "++", ifelse(qpwave_matrix > 0.01, "+", "")),
                     nrow = nrow(qpwave_matrix), ncol = ncol(qpwave_matrix))

# 指定人群
han <- scan("han.txt",what = '')
hui <- scan("hui.txt",what = '')
tu <- scan("tu.txt",what = '')
tibet <- scan("tibetan.txt",what = '')

qpwave_matrix_han <- qpwave_matrix[han,han]
qpwave_matrix_hui <- qpwave_matrix[hui,hui]
qpwave_matrix_tu <- qpwave_matrix[tu,tu]
qpwave_matrix_tibet <- qpwave_matrix[tibet,tibet]
annotation_tar <- matrix(ifelse(qpwave_matrix_hui > 0.05, "++", ifelse(qpwave_matrix_hui > 0.01, "+", "")),
                         nrow = nrow(qpwave_matrix_hui), ncol = ncol(qpwave_matrix_hui))
annotation_row <- data.frame(group=poplist$V1)
rownames(annotation_row) <- poplist$V1
annotation_col <- annotation_row
#画图
ht <- pheatmap(qpwave_matrix_hui, display_numbers = annotation_tar, main = 'pairwise qpWave rank=0', cutree_rows=1, cutree_cols = 1,
               fontsize_number = 20,cellwidth = 40,cellheight = 40,fontsize=20,
               #clustering_method = "ward.D2",
               color = colorRampPalette(c("white", "#A6CEE3"),alpha = 0.1)(100))
#               annotation_row = annotation_row, annotation_col = annotation_col)
#fontsize_row, fontsize_col改变横纵坐标名称字体大小 lab,xlab,ylab设置标题，横纵轴标签
pdf("pairwise_qpwave_hui.pdf",width =16,height =16)
print(ht)
dev.off()

sample_fns <- list.files(pattern = ".pop$")
for (s in sample_fns) {
  sample <- as.character(t(read.table(s, header=F)))
  pop <- file_path_sans_ext(s)
  qpwave_matrix_extract <- qpwave_matrix[rownames(qpwave_matrix) %in% sample, colnames(qpwave_matrix) %in% sample]
  annotation_extract <- matrix(ifelse(qpwave_matrix_extract > 0.05, "++", ifelse(qpwave_matrix_extract > 0.01, "+", "")),
                     nrow = nrow(qpwave_matrix_extract), ncol = ncol(qpwave_matrix_extract))
  if (length(sample) == 2) {
    # 手动设置颜色和图例分段点
    breaks <- seq(0, 0.2, length.out = 101)
    ht <- pheatmap(qpwave_matrix_extract, cluster_rows = FALSE, cluster_cols = FALSE,
                   fontsize_number = 20,cellwidth = 80,cellheight = 80,
                   display_numbers = annotation_extract, main = 'pairwise qpWave rank=0',
                   color = colorRampPalette(c("white", "#A6CEE3"),alpha = 0.1)(100),
                   gaps_row = 1, gaps_col = 1,breaks = breaks,
                   cutree_rows = 2, cutree_cols = 2
                   #annotation_row = annotation_row, annotation_col = annotation_col
                   #clustering_method = "ward.D2"
                   )
  } else {
    ht <- pheatmap(qpwave_matrix_extract, display_numbers = annotation_extract, main = 'pairwise qpWave rank=0',
                   fontsize = 20,cellwidth = 40,cellheight = 40,fontsize_number = 20,
                   color = colorRampPalette(c("white", "#A6CEE3"),alpha = 0.1)(100),
                   cutree_rows = 2, cutree_cols = 2
                   #clustering_method = "ward.D2"
                   )
  }
  pdf(paste0("pairwise_qpwave_",pop,".pdf"), width = 26, height = 26)
  print(ht)
  dev.off()
}