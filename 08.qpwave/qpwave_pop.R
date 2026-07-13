library(reshape2)
library(pheatmap)
setwd('D:/R/Rworking/popgenetics/roma_241121/qpwave/')
tail_fn <- 'tail_pop2.txt'
result_fn <- 'qpwave_pop2.pdf'

qpwave_p <- read.table(tail_fn,header = F)
poplist <- read.table('poplist.txt')
#加上poplist自由组合第一个和最后一个元素
qpwave_p <- rbind(qpwave_p,c('Roma_Pakistan1','Roma_Pakistan1',NA))
qpwave_p <- rbind(qpwave_p,c('VLR.SG','VLR.SG',NA))
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

# pop_out1 <- c('1UD21210100006','1UD21210100027','1UD21210100085','1UD21210100090','1UD21210100032',
#               '1UD21210100005','1UD21210100104','1UD21210100005','1UD21210100048','1UD21210100041')
# pop_out2 <- c('1UD21210100014','1UD21210100020','1UD21210100040','1UD21210100026','1UD21210100116','1UD21210100083')
# 
# qpwave_matrix_extract <- qpwave_matrix[!(rownames(qpwave_matrix) %in% pop_out1), !(colnames(qpwave_matrix) %in% pop_out1)]
# qpwave_matrix_extract <- qpwave_matrix_extract[!(rownames(qpwave_matrix_extract) %in% pop_out2),
#                                                !(colnames(qpwave_matrix_extract) %in% pop_out2)]
# 
# qpwave_matrix_out1 <- qpwave_matrix[rownames(qpwave_matrix) %in% pop_out1, colnames(qpwave_matrix) %in% pop_out1]
# qpwave_matrix_out2 <- qpwave_matrix[rownames(qpwave_matrix) %in% pop_out2, colnames(qpwave_matrix) %in% pop_out2]
# 
annotation <- matrix(ifelse(qpwave_matrix > 0.05, "++", ifelse(qpwave_matrix > 0.01, "+", "")),
                      nrow = nrow(qpwave_matrix), ncol = ncol(qpwave_matrix))
# annotation_extract <- matrix(ifelse(qpwave_matrix_extract > 0.05, "++", ifelse(qpwave_matrix_extract > 0.01, "+", "")),
#                              nrow = nrow(qpwave_matrix_extract), ncol = ncol(qpwave_matrix_extract))
# annotation_out1 <- matrix(ifelse(qpwave_matrix_out1 > 0.05, "++", ifelse(qpwave_matrix_out1 > 0.01, "+", "")),
#                           nrow = nrow(qpwave_matrix_out1), ncol = ncol(qpwave_matrix_out1))
# annotation_out2 <- matrix(ifelse(qpwave_matrix_out2 > 0.05, "++", ifelse(qpwave_matrix_out2 > 0.01, "+", "")),
#                           nrow = nrow(qpwave_matrix_out2), ncol = ncol(qpwave_matrix_out2))
#人群分类
annotation_row <- data.frame(group=poplist$V2)
rownames(annotation_row) <- poplist$V1
annotation_col <- annotation_row

ht_all <- pheatmap(qpwave_matrix, cluster_rows = TRUE, cluster_cols = TRUE, legend = TRUE, 
                   cutree_rows=3, cutree_cols=3,
                   fontsize_number = 36,cellwidth = 80,cellheight = 80,
                   display_numbers = annotation,main = 'pairwise qpWave rank=0', fontsize = 50,
                   color = colorRampPalette(c("white", "#A6CEE3"),alpha = 0.1)(100),
                   #breaks = breaks,
                   #gaps_row = 1, gaps_col = 1
                   annotation_row = annotation_row, annotation_col = annotation_col
)

pdf(result_fn,width = 70,height = 50)
print(ht_all)
dev.off()

# pdf('qpwave_extract.pdf',width = 60,height = 60)
# print(ht_extract)
# dev.off()
# 
# pdf('qpwave_out1.pdf',width = 30,height = 30)
# print(ht_out1)
# dev.off()
# 
# pdf('qpwave_out2.pdf',width = 30,height = 30)
# print(ht_out2)
# dev.off()