source("FinestructureLibrary16.R")
chunkfile<-paste("fs_linked.chunkcounts.out",sep="") ## chromopainter chunkcounts file
dataraw<-as.matrix(read.table(chunkfile,row.names=1,header=T,skip=1)) # read in the pairwise coincidence 

## PCA Principal Components Analysis
pcares<-mypca(dataraw)
print(pcares)
# For figuring out how many PCs are important; see Lawson & Falush 2012
# You need packages GPArotation and paran, and psych

## If you don't already have them:
# install.packages("psych")
# install.packages("paran")
# install.packages("GPArotation")
# install.packages("mclust")
library(psych)
library(paran)
library(GPArotation)
library(mclust)
tmap<-optimalMap(dataraw)
thorn<-optimalHorn(dataraw)
c(tmap,thorn) # 11 and 5. Horn typically underestimates, Map is usually better

treefile<-paste("fs_linked_tree.xml",sep="") ## finestructure tree file
treexml<-xmlTreeParse(treefile) ## read the tree as xml format
mappopchunkfile<-paste("fs_linked.mapstate.csv",sep="")
mapstate<-extractValue(treexml,"Pop") # map state as a finestructure clustering
mapstatelist<-popAsList(mapstate) # .. and as a list of individuals in populations

pcapops<-getPopIndices(rownames(dataraw),mapstatelist)
print(pcapops)
pcanames<-rownames(dataraw)
print(pcanames)

pops <- unlist(strsplit(pcanames,split="_[0123456789]+"))
print(pops)

library(plyr)

rcols<-rainbow(length(pops))
print(rcols)

fn=data.frame(pcanames,pops,rep(0,length(pcanames)),rep(0,length(pcanames)))
colnames(fn)<-c("indid","popid","pch","col")
bb=rep(c(0:20,35:37),100)
for(pop in pops){
  fn$pch[fn$popid == pop] <- bb[which(pops == pop)[1]]
  fn$col[fn$popid == pop] <- rcols[which(pops == pop)[1]]}
print(fn)

fn1<-data.frame(fn$popid,fn$pch,fn$col)
colnames(fn1)<-c("popid","pch","col")
fn2<-unique(fn1)

pdf("fs_PCA.pdf",height=10,width=10)
i=1;j=2
  plot(pcares$vectors[,i],pcares$vectors[,j],col=fn$col,xlab=paste("PC",i),ylab=paste("PC",j),main=paste("PC",i,"vs",j),pch=fn$pch)
  legend("topright",legend=fn2$popid, col= fn2$col, pch=fn2$pch,pt.cex=1.6,ncol=3, cex=1.07,xpd=TRUE,horiz= FALSE,bty = "n",title.adj=0)
  #text(pcares$vectors[,i],pcares$vectors[,j],labels=pcanames,col=rcols[pcapops],cex=0.5,pos=1)
dev.off()

