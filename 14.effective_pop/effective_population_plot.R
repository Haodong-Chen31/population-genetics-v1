library(ggplot2)
library(gcookbook)

setwd('D:/R/Rworking/popgenetics/roma_241109/ne/')
a <- read.table('ne.ne',header = T)
a_cut30 <- a[1:300,]
a_cut30$NE_log <- log(a_cut30$NE)
a_cut30$LOW_log <- log(a_cut30$LWR.95.CI)
a_cut30$UP_log <- log(a_cut30$UPR.95.CI)
a_cut30$pop <- 'roma'

p <- ggplot(a_cut30,aes(x=GEN,y=NE_log))+
  geom_ribbon(aes(ymin=LOW_log,ymax=UP_log),alpha=0.2)+
  geom_line(cex=1.5)+
  labs(y = 'log(Effective population size)',x = 'Generations before present')+
  theme_bw()+
  theme(plot.title = element_text(size = 15,hjust = 0.5,face = 'bold'))+
  scale_x_continuous(breaks=seq(0,300,30))+
  facet_wrap(~pop)

p
ggsave('effective_population_300.pdf',width = 6,height = 6)