library(ggplot2)

args = commandArgs(trailingOnly = TRUE)
#fn <- args[1]
fn <- "cv_error.txt"
cv_error <- read.table(fn)

p <- ggplot(cv_error,aes(V3,V4))+
  geom_line(color='steelblue',linewidth=1)+geom_point(color='orangered')+
  scale_x_continuous(breaks = unique(cv_error$V3))+
  theme_classic()+theme(panel.grid=element_blank())+
  xlab('K')+ylab('CV error')+
  #设置x,y轴标题字体大小
  theme(axis.title.x = element_text(size = 14,face = 'bold'),  #x 12
        axis.title.y = element_text(size = 14,face = 'bold'))+ #y 14
  theme(axis.text.x = element_text(size = 12), #x 10
        axis.text.y = element_text(size = 12)) #y 10
p
ggsave('admix_CVerror.pdf')
