library(reshape2)
library(dplyr)
library(pheatmap)

# setwd("E:/Rworking/popgenetics/aim_251204/f3/")
# 
# 
# fst <- read.table('result_fst_for_r',row.names = 1, header = FALSE)
# #outf3_matrix <- acast(outf3, source_1~source_2, value.var="f_3", drop = F)
# 
# heatmap
pdf('fst_heatmap.pdf',width =50,height =50)
heatmap(fst,
        cexRow = 2.5, cexCol = 2.5,
        margins = c(40, 40),
        #Colv = NA, Rowv = NA
        )
dev.off()

# pheatmap
# pdf('outf3_heatmap2.pdf',width =50,height =50)
# pheatmap(outf3_matrix,
#          fontsize = 12,           # 基本字体大小
#          fontsize_row = 10,       # 行标签字体
#          fontsize_col = 10,       # 列标签字体
#          fontsize_number = 8,     # 单元格内数字字体（如果显示）
#          main = "Heatmap",
#          fontsize_main = 16,      # 标题字体
#          cellwidth = 15,          # 单元格宽度
#          cellheight = 15,         # 单元格高度
#          display_numbers = FALSE) # 是否在单元格显示数值
# dev.off()

# 1. 读取数据（先不要设 row.names，因为我们要手动清洗）
fst_raw <- read.table('result_fst_for_r', header = FALSE, fill = TRUE, stringsAsFactors = FALSE)

# 2. 观察发现：真正的 Fst 数据行是那些第一列不包含 "====" 的行
# 我们只保留包含省份名称的行（如 Anhui_Han, Fujian_Han 等）
fst_clean <- fst_raw[!grepl("====", fst_raw$V1), ]

# 3. 设置行名：将第一列（人群名）设为行名
rownames(fst_clean) <- fst_clean$V1

# 4. 移除第一列（因为它现在是字符串，会干扰矩阵转换）
fst_numeric_df <- fst_clean[, -1]

# 5. 转换为数值矩阵（强制转换，防止里面有残留的字符型数字）
fst_matrix <- as.matrix(fst_numeric_df)
fst_matrix <- matrix(as.numeric(fst_matrix), nrow = nrow(fst_matrix))

# 6. 还原行列名（矩阵转换过程中可能会丢失）
rownames(fst_matrix) <- rownames(fst_clean)
# 假设是 16 个人群，如果列名没有，可以根据行名手动赋予，确保是对称矩阵
colnames(fst_matrix) <- rownames(fst_clean) 

# 找到名为 "Guangxi_Han" 的行和列并剔除
fst_matrix <- fst_matrix[rownames(fst_matrix) != "Guangxi_Han", 
                         colnames(fst_matrix) != "Guangxi_Han"]
# 7. 绘图
pdf('fst_new_heatmap_noguangxi.pdf', width = 12, height = 10)
pheatmap(as.matrix(fst_matrix),
         clustering_method="ward.D2",
         cutree_col = 4,cutree_row = 4,display_numbers = F,  number_format = "%.3f")
dev.off()
