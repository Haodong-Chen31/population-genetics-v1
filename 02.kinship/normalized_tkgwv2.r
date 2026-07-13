setwd('E:/Project/Shandong/kinships')
fn <- read.table("TKGWV2_Results.txt",header=T,sep="\t")
Unrelated_data <- read.table("unrelated.txt",header=T,sep="\t")
unrelated_mean <- mean(Unrelated_data$HRC)
fn$normalized_HRC <- NA
fn$normalized_related <- NA
b <- length(fn$HRC)
for (i in 1:b){
    fn$normalized_HRC[i]=fn$HRC[i]-unrelated_mean
    if (fn$normalized_HRC[i] < 0.0625){
      fn$normalized_related[i]  = "Unrelated"
      } else if(fn$normalized_HRC[i] >= 0.0625&fn$normalized_HRC[i] < 0.1875){
    fn$normalized_related[i]  = "2nd degree"
        } else if(fn$normalized_HRC[i] >= 0.1875&fn$normalized_HRC[i] < 0.3125){
      fn$normalized_related[i]  = "1st degree"
        } else {
          fn$normalized_related[i]  = "Same individual/Twins"
        } 
    
    
}
unrelated_median <- median(fn$HRC)
fn$normalized_median_HRC <- NA
fn$normalized_median_related <- NA
b <- length(fn$HRC)
for (i in 1:b){
  fn$normalized_median_HRC[i]=fn$HRC[i]-unrelated_median
  if (fn$normalized_median_HRC[i] < 0.0625){
    fn$normalized_median_related[i]  = "Unrelated"
  } else if(fn$normalized_median_HRC[i] >= 0.0625&fn$normalized_median_HRC[i] < 0.1875){
    fn$normalized_median_related[i]  = "2nd degree"
  } else if(fn$normalized_median_HRC[i] >= 0.1875&fn$normalized_median_HRC[i] < 0.3125){
    fn$normalized_median_related[i]  = "1st degree"
  } else {
    fn$normalized_related[i]  = "Same individual/Twins"
  } 
  
  
}
write.table(fn,file="normalized_TKGWV2_Results.txt",row.names =TRUE, col.names =TRUE,sep="\t", quote =FALSE)
