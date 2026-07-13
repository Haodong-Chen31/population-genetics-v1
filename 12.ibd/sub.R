args = commandArgs(trailingOnly = TRUE)
all <- args[1]

a <- read.table(all)
for (i in 1:nrow(a)) {
  for (j in 1:nrow(a)) {
    if (a[i,1]==a[j,2] && a[i,2]==a[j,1]) {
      a[i,1] <- a[j,1]
      a[i,2] <- a[j,2]
    }
  }
}

write.table(a,'all2.txt',row.names = F,col.names = F,quote = F)
