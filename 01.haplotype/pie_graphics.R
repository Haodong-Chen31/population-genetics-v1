library(graphics)
library(randomcoloR)
library(RColorBrewer)
my_color <- brewer.pal(12,'Set3')
setwd('D:/R/Rworking/popgenetics/xjcd/haplotype/')

for (i in c('mt','y')) {
  file_name <- paste0(i, '_haplo.txt')
  # 检查文件是否存在
  if (!file.exists(file_name)) {
    message(paste("File", file_name, "does not exist. Skipping..."))
    next
  }
  data <- read.table(file_name,sep = ',',col.names = c('haplogroup','num'))
  data$percent <- paste0(round(data$num / sum(data$num) * 100,2),'%')
  pdf(paste0(i,'haplo_pie.pdf'),width = 8,height = 6)
  pie(data$num,labels = with(data,paste0(haplogroup,"(",percent,")")),
      main = paste0(toupper(i),' haplogroups of individuals in\n Xujiacundong & Zhouhe sites ( n=',sum(data$num),' )'),col = my_color)
  dev.off()
}