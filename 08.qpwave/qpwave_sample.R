library(reshape2)
library(pheatmap)
setwd('D:/R/Rworking/popgenetics/roma_241121/qpwave/')
tail_fn <- 'tail_sample.txt'
result_fn <- 'qpwave_all_samples_moren.pdf'

qpwave_p <- read.table(tail_fn,header = F)
#加上poplist自由组合第一个和最后一个元素
qpwave_p <- rbind(qpwave_p,c('1UD21210100009','1UD21210100009',NA))
qpwave_p <- rbind(qpwave_p,c('1UD21210100020','1UD21210100020',NA))
#转长格式为宽格式
qpwave_matrix <- acast(qpwave_p, V1~V2, value.var="V3", drop = F)

#转为对称矩阵
for (i in 1:nrow(qpwave_matrix)) {
  for (j in 1:ncol(qpwave_matrix)) {
    if (is.na(qpwave_matrix[i,j])){
      qpwave_matrix[i,j] <- qpwave_matrix[j,i]
    }
  }
}
#将矩阵所有元素转为数字类型
qpwave_matrix <- apply(qpwave_matrix, c(1,2), as.numeric) 
#qpwave_matrix <- qpwave_matrix[rownames(qpwave_matrix) != "1UD21210100037", colnames(qpwave_matrix) != "1UD21210100037"]
# qpwave_matrix <- qpwave_matrix[rownames(qpwave_matrix) != "1UD21210100023", colnames(qpwave_matrix) != "1UD21210100023"]
# qpwave_matrix <- qpwave_matrix[rownames(qpwave_matrix) != "1UD21210100089", colnames(qpwave_matrix) != "1UD21210100089"]

pop_out1 <- c('1UD21210100006','1UD21210100085','1UD21210100090','1UD21210100032','1UD21210100041','1UD21210100027',
              '1UD21210100083','1UD21210100005')
pop_out2 <- c('1UD21210100014','1UD21210100020','1UD21210100040','1UD21210100026','1UD21210100116')

qpwave_matrix_extract <- qpwave_matrix[!(rownames(qpwave_matrix) %in% pop_out1), !(colnames(qpwave_matrix) %in% pop_out1)]
qpwave_matrix_extract <- qpwave_matrix_extract[!(rownames(qpwave_matrix_extract) %in% pop_out2),
                                               !(colnames(qpwave_matrix_extract) %in% pop_out2)]

qpwave_matrix_out1 <- qpwave_matrix[rownames(qpwave_matrix) %in% pop_out1, colnames(qpwave_matrix) %in% pop_out1]
qpwave_matrix_out2 <- qpwave_matrix[rownames(qpwave_matrix) %in% pop_out2, colnames(qpwave_matrix) %in% pop_out2]

annotation <- matrix(ifelse(qpwave_matrix > 0.05, "++", ifelse(qpwave_matrix > 0.01, "+", "")),
                     nrow = nrow(qpwave_matrix), ncol = ncol(qpwave_matrix))
annotation_extract <- matrix(ifelse(qpwave_matrix_extract > 0.05, "++", ifelse(qpwave_matrix_extract > 0.01, "+", "")),
                     nrow = nrow(qpwave_matrix_extract), ncol = ncol(qpwave_matrix_extract))
annotation_out1 <- matrix(ifelse(qpwave_matrix_out1 > 0.05, "++", ifelse(qpwave_matrix_out1 > 0.01, "+", "")),
                          nrow = nrow(qpwave_matrix_out1), ncol = ncol(qpwave_matrix_out1))
annotation_out2 <- matrix(ifelse(qpwave_matrix_out2 > 0.05, "++", ifelse(qpwave_matrix_out2 > 0.01, "+", "")),
                          nrow = nrow(qpwave_matrix_out2), ncol = ncol(qpwave_matrix_out2))

ht_all <- pheatmap(qpwave_matrix, cluster_rows = TRUE, cluster_cols = TRUE, legend = TRUE, 
                   cutree_rows=5, cutree_cols=5,
                   #clustering_method = "ward.D2",
                   fontsize_number = 36,cellwidth = 80,cellheight = 80,
                   display_numbers = annotation,main = 'pairwise qpWave rank=0', fontsize = 50,
                   color = colorRampPalette(c("white", "#A6CEE3"),alpha = 0.1)(100)
                   #breaks = breaks,
                   #gaps_row = 1, gaps_col = 1
                   #annotation_row = annotation_row, annotation_col = annotation_col
)
ht_pop1 <- pheatmap(qpwave_matrix_extract, cluster_rows = TRUE, cluster_cols = TRUE, legend = TRUE, 
                   #cutree_rows=3, cutree_cols=3,
                   fontsize_number = 36,cellwidth = 80,cellheight = 80,
                   display_numbers = annotation_extract,main = 'Pop1 —— pairwise qpWave rank=0', fontsize = 50,
                   color = colorRampPalette(c("white", "#A6CEE3"),alpha = 0.1)(100)
                   #breaks = breaks,
                   #gaps_row = 1, gaps_col = 1
                   #annotation_row = annotation_row, annotation_col = annotation_col
)
ht_pop2 <- pheatmap(qpwave_matrix_out1, cluster_rows = TRUE, cluster_cols = TRUE, legend = TRUE, 
                   #cutree_rows=3, cutree_cols=3,
                   fontsize_number = 36,cellwidth = 80,cellheight = 80,
                   display_numbers = annotation_out1,main = 'Pop2 —— pairwise qpWave rank=0', fontsize = 50,
                   color = colorRampPalette(c("white", "#A6CEE3"),alpha = 0.1)(100)
                   #breaks = breaks,
                   #gaps_row = 1, gaps_col = 1
                   #annotation_row = annotation_row, annotation_col = annotation_col
)
ht_pop3 <- pheatmap(qpwave_matrix_out2, cluster_rows = TRUE, cluster_cols = TRUE, legend = TRUE, 
                   #cutree_rows=3, cutree_cols=3,
                   fontsize_number = 36,cellwidth = 80,cellheight = 80,
                   display_numbers = annotation_out2,main = 'Pop3 —— pairwise qpWave rank=0', fontsize = 50,
                   color = colorRampPalette(c("white", "#A6CEE3"),alpha = 0.1)(100)
                   #breaks = breaks,
                   #gaps_row = 1, gaps_col = 1
                   #annotation_row = annotation_row, annotation_col = annotation_col
)
# ht_sd <- pheatmap(qpwave_matrix_shandong_he, cluster_rows = FALSE, cluster_cols = FALSE, legend = TRUE, 
#                   fontsize_number = 36,cellwidth = 60,cellheight = 60,
#                   display_numbers = annotation_sd,main = 'pairwise qpWave rank=0', fontsize = 36
#                   #breaks = breaks,
#                   #gaps_row = 1, gaps_col = 1
#                   #annotation_row = annotation_row, annotation_col = annotation_col
# )
#fontsize_row, fontsize_col改变横纵坐标名称字体大小 lab,xlab,ylab设置标题，横纵轴标签

pdf(result_fn,width = 70,height = 70)
print(ht_all)
dev.off()

pdf('qpwave_sample1.pdf',width = 60,height = 60)
print(ht_pop1)
dev.off()

pdf('qpwave_sample2.pdf',width = 30,height = 30)
print(ht_pop2)
dev.off()

pdf('qpwave_sample3.pdf',width = 30,height = 30)
print(ht_pop3)
dev.off()