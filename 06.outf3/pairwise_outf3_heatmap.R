library(reshape2)
library(dplyr)
library(pheatmap)

setwd("E:/Rworking/popgenetics/aim_251204/f3/")


outf3 <- read.csv('outf3_1240k.r.csv')
outf3_matrix <- acast(outf3, source_1~source_2, value.var="f_3", drop = F)

# heatmap
pdf('outf3_heatmap.pdf',width =50,height =50)
heatmap(outf3_matrix,
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
