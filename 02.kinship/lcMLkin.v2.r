#!/usr/bin/env Rscript

#usage: Rscript lcMLkin.r $dir $prefix(relate file)
args = commandArgs(trailingOnly=TRUE)
options(scipen=999)
library(ggrepel)
library(ggplot2)
setwd(args[1])
kinship<-read.table(paste(args[1],"/",args[2],".relate",sep=""),header=T)
kinship$names<-paste(kinship$Ind1,kinship$Ind2,sep="-")
kinship$r <- NA
kinship$related <- NA
b <- length(kinship$k0_hat)
for (i in 1:b){
  kinship$r[i]=(kinship$k1_hat[i]/2)+kinship$k2_hat[i]
  if (kinship$r[i]==1){
    kinship$related[i]="same individual/Identical Twins"
  } else if(kinship$r[i]>=0.5&kinship$r[i]<1&&kinship$k0_hat[i]==0){
    kinship$related[i]="parent-offspring"
  } else if(kinship$r[i]>=0.5&kinship$r[i]<1&&kinship$k0_hat[i]>0){
    kinship$related[i]="sibling"
  } else if(kinship$r[i]>=0.25&kinship$r[i]<0.5){
    kinship$related[i]="2nd degree"
  } else if(kinship$r[i]>=0.125&kinship$r[i]<0.25){
    kinship$related[i]="3th degree"
  } else if(kinship$r[i]>=0.0625&kinship$r[i]<0.125){
    kinship$related[i]="4th degree"
  } else {
    kinship$related[i]="unrelated"
  }
}
kinship$degree<-NA
for(i in 1:b){
   if (kinship$pi_HAT[i]==1){
    kinship$degree[i]="same individual/Identical Twins"
  } else if(kinship$pi_HAT[i]>=0.5&kinship$pi_HAT[i]<1&&kinship$k0_hat[i]==0){
    kinship$degree[i]="parent-offspring"
  } else if(kinship$pi_HAT[i]>=0.5&kinship$pi_HAT[i]<1&&kinship$k0_hat[i]>0){
    kinship$degree[i]="sibling"
  } else if(kinship$pi_HAT[i]>=0.25&kinship$pi_HAT[i]<0.5){
    kinship$degree[i]="2nd degree"
  } else if(kinship$pi_HAT[i]>=0.125&kinship$pi_HAT[i]<0.25){
    kinship$degree[i]="3th degree"
  } else if(kinship$pi_HAT[i]>=0.0625&kinship$pi_HAT[i]<0.125){
    kinship$degree[i]="4th degree"
  } else {
    kinship$degree[i]="unrelated"
  }

}
 write.table(kinship,file=paste(args[1],"/",args[2],"_relate.txt",sep=""),row.names =TRUE, col.names =TRUE, sep="\t",quote =FALSE)
kinship$labels<-NA
kinship$pchs<-NA
b <- length(kinship$k0_hat)
for (i in 1:b){
    if (kinship$pi_HAT[i]>=0.0625){
          kinship$labels[i]=kinship$names[i]
  } 
}
b <- length(kinship$k0_hat)
for (i in 1:b){
  if (kinship$nbSNP[i]<=1000){
  kinship$pchs[i]=0
  } else {
  kinship$pchs[i]=1
  }
}
ggplot(data=kinship,aes(x=k0_hat,y=pi_HAT))+
    geom_point(data=kinship,aes(x=k0_hat,y=pi_HAT,color=degree,shape=factor(pchs)),size=2)+
    theme_bw()+xlim(0,1)+
    #scale_color_manual(values=c("#008200","#f96406","#b3e5fc"))+
    geom_text_repel(aes(x=k0_hat,y=pi_HAT,label=labels), size=2)
ggsave(file=paste(args[1],"/",args[2],".pdf",sep=""),width=10,height=10)