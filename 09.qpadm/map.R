library(terra)
library(ggplot2)
library(sf)
library(rnaturalearth)
library(rnaturalearthdata)
library(plyr)
## 这个包需要手动装
##install.packages('./map_data/rgdal_1.6-7.tar.gz', repos = NULL, type = 'source')
library(rgdal)
library(RColorBrewer)
library(scatterpie)
library(ggtext)

setwd('D:/R/Rworking/popgenetics/roma_241121/qpadm')
source("D:/R/Rworking/study/超级帅的地图绘制V2/超级帅的地图绘制V2/map_data/plot_yellow_river_yangtze_v2.R")
source("D:/R/Rworking/study/超级帅的地图绘制V2/超级帅的地图绘制V2/map_data/map_data_extract.R")

data_new_plot <- read.csv("roma_qpadm_map2.csv",
                          stringsAsFactors = F)
col_data <- colnames(data_new_plot)[2:4]

## 自动配色，挑选自己喜欢的颜色方案
display.brewer.all()
display.brewer.pal(12,"Paired")
colour_all <- brewer.pal(12,"Paired")

## 是否要高亮黄河和长江 区域 TRUE OR FALSE
plot_yellow_river_yangtze_logical_value <- FALSE

## 底图需要绘制的区域
plot_region <- ext(12, 89, 8, 62)

map_all_data <- map_data_extract(map_position="D:/R/Rworking/study/超级帅的地图绘制V2/超级帅的地图绘制V2/map_data/NE2_HR_LC_SR_W_DR.tif",extract_value=plot_region)

#底图
p_earth <- ggplot()+
  geom_raster(map_all_data,mapping=aes(x = x, y = y), fill = rgb(map_all_data$R,map_all_data$G,map_all_data$B))+
  theme(axis.title.x = element_blank(), 
        axis.title.y = element_blank(),
        axis.ticks = element_blank(), 
        panel.background = element_rect(fill = NA), 
        panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        panel.border = element_blank()) + 
  #theme(legend.position = "none")+ 
  scale_y_continuous(breaks = NULL)+
  scale_x_continuous(breaks = NULL)+
  coord_sf()

if(plot_yellow_river_yangtze_logical_value){
  out_data <- plot_yellow_river_yangtze_v2(plot_yellow_river_yangtze_logical_value)
  river1 <- out_data$river_1
  river2 <- out_data$river_2
  p_earth_river <- p_earth+
    geom_path(data=river1, aes(x = long, y = lat, group = group), color = '#5EB8CE',linewidth=1.6)+
    #geom_sf(data = river1, color= "#5EB8CE", linewidth=1.6)+
    geom_path(data=river2, aes(x = long, y = lat, group = group), color = '#5EB8CE', linewidth=1.6)+
    coord_sf()
}

p1 <- p_earth+geom_scatterpie(data = data_new_plot, aes(x = long, y = lat,  r = 2), 
                       cols=col_data, color = "black", alpha=.9,
                       legend_name = 'Source'
                       ) +  # 在指定的经纬度位置添加饼图
  ## 设置颜色，RColorBrewer里面的
  scale_fill_manual(values = c(colour_all[5],colour_all[11],colour_all[3]))+
  #图例字大小
  theme(legend.text =element_text(size = 15))+
  #图例标题字大小
  theme(legend.title = element_text(size = 10,face = 'bold'))+
  theme(legend.position = "bottom")+
  geom_richtext(data=data_new_plot,
                aes(x=long,y=lat,label=Target),
                vjust=1.8,label.colour = NA,
                fill="transparent")+ 
  coord_equal()

ggsave('map_roma_10.pdf',p1,width =10,height =10)
