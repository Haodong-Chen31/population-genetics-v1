library(ggplot2)
library(cowplot)
library(tidyr)
library(dplyr)

setwd('D:/R/Rworking/popgenetics/xjcd/qpadm/')
# # 创建示例数据框
# data <- data.frame(
#   Group = c("Nagqu1.6k|0.01", "Nagqu1.6k|0.01", "Nagqu1.4k", "Nagqu1.4k", "Nagqu1.1k", "Nagqu1.1k", "Nagqu1.1k"),
#   Value = c(0.8, 0.2, 0.75, 0.25, 0.7, 0.1, 0.2),
#   Error = c(0.05, 0.04, 0.03, 0.02, 0.01, 0.02,0.05),
#   Error_bg = c(0, 0.8, 0, 0.75, 0, 0.9, 0.7),
#   p = c(0.01,0.01,0.01,0.01,0.01,0.01,0.01),
#   Category = c("Lubrak", "Chamdo2.8k_1", "Lubrak", "Yushu2.8k", "Lubrak", "Chamdo2.8k_1","Yushu2.8k")
# )

input <- "xjcd_qpadm_0222.csv"
output <- 'qpadm_xjcd_0222.pdf'
data <- read.csv(input, header=T)
# 转换为长格式
l <- data %>%
  pivot_longer(cols = c(YR_LN, Sanlihe_LS,Ami.DG,Baojianshan,AR_EN), 
               names_to = "source", 
               values_to = "source_value") %>%
  pivot_longer(cols = c(std_err1, std_err2, std_err3, std_err4, std_err5), 
               names_to = "std_err_source", 
               values_to = "std_err") %>%
  pivot_longer(cols = c(err1_bg, err2_bg, err3_bg, err4_bg, err5_bg),
               names_to = "std_err_bg_source",
               values_to = "std_err_bg")
long_data <- data %>%
  pivot_longer(cols = c(YR_LN, Sanlihe_LS,Ami.DG,Baojianshan,AR_EN), 
               names_to = "source", 
               values_to = "source_value") %>%
  pivot_longer(cols = c(std_err1, std_err2, std_err3, std_err4, std_err5), 
               names_to = "std_err_source", 
               values_to = "std_err") %>%
  pivot_longer(cols = c(err1_bg, err2_bg, err3_bg, err4_bg, err5_bg),
               names_to = "std_err_bg_source",
               values_to = "std_err_bg") %>%
  filter((source == "YR_LN" & std_err_source == "std_err1" & std_err_bg_source == "err1_bg") |
           (source == "Sanlihe_LS" & std_err_source == "std_err2" & std_err_bg_source == "err2_bg") |
           (source == "Ami.DG" & std_err_source == "std_err3" & std_err_bg_source == "err3_bg") |
           (source == "Baojianshan" & std_err_source == "std_err4" & std_err_bg_source == "err4_bg") |
           (source == "AR_EN" & std_err_source == "std_err5" & std_err_bg_source == "err5_bg")) %>%
  select(target, source, source_value, std_err, std_err_bg)
long_data$source <- factor(long_data$source,levels = rev(c("YR_LN","Sanlihe_LS","Ami.DG","Baojianshan","AR_EN")))
long_data$target <- factor(long_data$target, levels=rev(unique(long_data$target)))
#long_data_rev <- slice(long_data, n():1)

# 绘制图形
p <- ggplot(long_data, aes(x = target, y = source_value, fill = source)) +
  geom_bar(position="stack", stat='identity', width=.8, color='black') +
  geom_errorbar(aes(ymin = std_err_bg, ymax = std_err_bg+std_err), width = 0.4) +
  scale_fill_manual(values = c('YR_LN'="#FDBF6F",'Sanlihe_LS'="#FB9A99",'Ami.DG'="#5EB8CE88", 
                               'Baojianshan'='#9D7BBA88', 'AR_EN'='#B2DF8A')) +
  theme_minimal() +
  labs(x = "", y = "", fill = "") +
  theme_cowplot(font_size = 16) + 
  guides(fill=guide_legend(reverse=TRUE)) +
  # 堆积图文字
  geom_text(aes(label=source_value), position=position_stack(vjust=0.5), size=3.4) +
  # 图例文字
  theme(legend.position = "bottom")+
  # 90°
  coord_flip()

ggsave(output, p, bg = 'white', width = 10, height = 6.6)
