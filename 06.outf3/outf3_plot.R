library(ggplot2)
library(patchwork)
library(dplyr)

setwd('D:/R/Rworking/popgenetics/ganqing_0119/outf3/')
f3 <- read.csv('outf3_HO.r.csv',header = T)
pop_for_plot <- as.character(t(read.table('poplist.txt',header = F)))
target <- as.character(t(read.table('target.txt',header = F)))
target_count <- 15
modern_count <- 52
ancient_count <- 132
total_count <- modern_count + ancient_count
f3$f_3 <- as.numeric(f3$f_3)
modern_or_ancient <- rep(c(rep("modern", modern_count), rep("ancient", ancient_count)), target_count)
f3$time <- modern_or_ancient

f3_p <- c()
for (tar in target) {
  for (tim in c('modern','ancient')) {
    targ <- f3 %>%
      subset(source_1 == tar & snps > 30000 & time == tim & source_2 %in% pop_for_plot) %>%
      arrange(desc(f_3)) %>%
      head(30)
    f3_p <- rbind(f3_p,targ)
  }
}

data_list <- lapply(target, function(tar) {
  f3_p %>%
  filter(source_1 == tar) %>%
  arrange(desc(f_3)) %>%
  mutate(source_2 = reorder(source_2, f_3))
})

#每个群体画一张图
#数据放入list
num <- seq(1,length(data_list))
plot_list <- lapply(num, function(df_name) {
  df <- data_list[[df_name]]
  pop <- unique(df$source_1)
  p <- ggplot(df,aes(x=f_3,y=source_2))+
    geom_errorbar(aes(xmin=f_3-std.err, xmax=f_3+std.err),width=0.3,color='black')+
    geom_point(size=2.5,color='orange')+
    #标题 也可x y标题 标题换行：把要换行部分用\n隔开
    labs(y = '',x = '',title = paste0('outf3(',pop,',X;Mbuti)'))+ #
    #白底灰线主题
    theme_bw()+
    #theme(panel.grid=element_blank())+
    #标题大小及居中,并加粗显示
    theme(plot.title = element_text(size = 17,hjust = 0.5,face = 'bold'))+
    #标题在图中theme
    #(plot.title = element_text(vjust = -6))+
    #设置x,y轴字体大小
    theme(axis.text.x = element_text(size = 12), #x 分面x轴字体大小也调这
          axis.text.y = element_text(size = 14))+ #y 分面y轴字体大小也调这
    #设置x,y轴标题字体大小
    theme(axis.title.x = element_text(size = 14,face = 'bold'),  #x 12
          axis.title.y = element_text(size = 14,face = 'bold'))+ #y 14
    #图例位置
    theme(legend.position = 'right')+
    #图例大小
    theme(legend.key.size = unit(1, "cm"))+
    #图例字大小
    theme(legend.text =element_text(size = 8))+
    #图例标题字大小
    theme(legend.title = element_text(size = 10))+
    #x轴范围
    #scale_x_continuous(limits = c(0.285,0.315))+
    facet_wrap(~time,scales = 'free_y')+
    theme(strip.text.x = element_text(size = 14)) #分面x的文字大小
  return(p)
})
p_final <- wrap_plots(plot_list, ncol = 5)

ggsave('outf3_gq_0119.pdf',p_final,width = 34,height = 20)
