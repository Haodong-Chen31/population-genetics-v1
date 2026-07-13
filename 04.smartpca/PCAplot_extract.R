library(dplyr)
library(ggplot2)

pca_plot_extract <- function(data = mergedEvecDat, 
                            pop_data = popGroups,
                            x_var = "PC1", 
                            y_var = "PC2",
                            target_only = FALSE,
                            x_filter = c(-0.022, 0.0022),
                            y_filter = c(-0.035, 0.0004),
                            target_pops = c('Han_Linxia', 'Han_Xiahe', 'Han_Gangou', 'Han_Wutun1', 
                                            'Han_Wutun2', 'Han_Wutun_o','Hui_Linxia1', 'Hui_Linxia2',
                                            'Hui_Linxia_o', 'Tibetan_Gangou','Tibetan_Wutun1',
                                            'Tibetan_Wutun2', 'Tu_Gangou', 'Tu_Wutun','Tu_Wutun_o'),
                            output_file = "PCAplot_extract.pdf",
                            plot_width = 42,
                            plot_height = 30) {
  
  # 数据筛选
  mergedEvecDat_extract <- data[data$PC1 >= x_filter[1] & data$PC1 <= x_filter[2] & 
                                  data$PC2 >= y_filter[1] & data$PC2 <= y_filter[2], ]
  
  # 添加标签
  mergedEvecDat_extract <- mergedEvecDat_extract %>%
    mutate(label = ifelse(Pop %in% target_pops, 't', 'n'))
  
  # 如果只显示目标人群，则进一步筛选
  if (target_only) {
    mergedEvecDat_extract <- mergedEvecDat_extract %>%
      filter(Pop %in% target_pops)
  }
  
  # 处理人群分组数据
  extract_pop <- unique(sort(mergedEvecDat_extract$Pop))
  popGroups_extract <- pop_data[pop_data$Pop %in% extract_pop, ]
  
  popGroups_extract <- popGroups_extract %>%
    mutate(label = ifelse(Pop %in% target_pops, 't', 'n'))
  
  # 设置因子水平
  v2 <- factor(mergedEvecDat_extract$Pop, levels = popGroups_extract$Pop)
  
  # 创建绘图
  p_extrac <- ggplot(mergedEvecDat_extract, aes(x = .data[[x_var]], y = .data[[y_var]], 
                                                color = v2, shape = v2, fill = v2)) +
    geom_point(size = 20, stroke = 6) +
    # 设置图案形状
    scale_shape_manual(name = "", labels = popGroups_extract$Pop,
                       values = popGroups_extract$symbol) +
    # 设置图案颜色
    scale_color_manual(name = "", labels = popGroups_extract$Pop,
                       values = popGroups_extract$col) +
    # 设置图案填充
    scale_fill_manual(name = "", labels = popGroups_extract$Pop,
                      values = popGroups_extract$fill) +
    # 图例列数
    guides(shape = guide_legend(ncol = 5), 
           color = guide_legend(ncol = 5), 
           fill = guide_legend(ncol = 5)) +
    # 背景主题
    theme_classic() +
    # 图例边框颜色
    theme(legend.background = element_rect(colour = "white")) +
    # 图例位置
    theme(legend.position = "none") +
    # 图例字大小
    theme(legend.text = element_text(size = 32)) +
    # x,y轴字体大小
    theme(axis.text.x = element_text(size = 60),
          axis.text.y = element_text(size = 60)) +
    # x, y标题字体大小
    theme(axis.title.x = element_blank(),
          axis.title.y = element_blank()) +
    xlab(paste0(x_var)) +
    ylab(paste0(y_var)) +
    # 绘制图边框
    theme(panel.border = element_rect(fill = NA, color = "black", linewidth = 3, linetype = "solid")) +
    # 图边框和图片边框距离
    theme(plot.margin = unit(c(2, 2, 2, 2), "cm"))
  
  # 保存图片
  ggsave(output_file, p_extrac, width = plot_width, height = plot_height)
  
  # 返回mergedEvecDat和popGroups两个数据框
  result_extract_list <- list(
    mergedEvecDat_extract = mergedEvecDat_extract,
    p_extrac = p_extrac
  )
  
  # 返回绘图对象
  return(result_extract_list)
}

# 使用示例：
# 1. 使用默认参数（PC1 vs PC2，显示所有人群）
# p1 <- create_pca_plot()

# 2. 使用PC2 vs PC3，只显示目标人群
# p2 <- create_pca_plot(x_var = "PC2", y_var = "PC3", target_only = TRUE)

# 3. 自定义筛选条件和输出文件
# p3 <- create_pca_plot(x_filter = c(-0.03, 0.01), 
#                      y_filter = c(-0.04, 0.005),
#                      output_file = "my_pca_plot.pdf")