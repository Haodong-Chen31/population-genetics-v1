library(ggrepel)
library(ggplot2)
setwd('E:/Project/Shandong/kinships')
fn <- read.table("tkgwv2.result",header=T,sep="\t")
fn$names<-paste(fn$Sample1,fn$Sample2,sep="-")
a=a <- length(fn$names)
fn$labels<-NA
for (i in 1:a){
  if (fn$normalized_HRC[i]>=0.0625){
    fn$labels[i]=fn$names[i]
  } 
}
ggplot(data=fn,aes(x=Used_SNPs,y=normalized_HRC))+
  geom_point(data=fn,aes(x=Used_SNPs,y=normalized_HRC,color=Relationship_normalized),size=2)+
  geom_hline(yintercept = c(0.0625,0.1875,0.3),colour = "black",linetype=2)+theme_bw()+
  #scale_color_manual(values=c("#008200","#f96406","#b3e5fc"))+
  geom_text_repel(aes(x=Used_SNPs,y=normalized_HRC,label=labels), size=2)
ggsave("normalized_TKGWV2.pdf",width=10,height=10)
