library(reshape2)
library(pheatmap)
library(ggplot2)
library(dplyr)

# 设置工作目录
setwd('E:/Rworking/popgenetics/yunnanbai/f4_260518/')

# 1. 加载数据
f4_score <- read.csv('f4_ancient_2.csv', header = T, check.names = F)

# 2. 读取人群列表
target_list <- scan('target.pop', what = '')       # 原 Z
a_list      <- scan('yr.txt', what = '')   # 原 X
b_list      <- scan('poplist_ancient.txt', what = '') # 原 Y

b_list <- b_list[!(b_list %in% target_list)]
# --- 配置区：在此自定义角色 ---
# 可选值: "target", "a", "b"
OUT_VAR <- "a"  # 决定输出多少个文件a
X_AXIS  <- "b"       # 热图的横轴人群b
Y_AXIS  <- "target"       # 热图的纵轴人群target
# ---------------------------

# 获取对应的人群集合
get_pop <- function(name) {
  if (name == "target") return(target_list)
  if (name == "a") return(a_list)
  if (name == "b") return(b_list)
}

# 自动映射列名 (对应 csv 里的列名: W, X, Y, Z)
# 根据你的代码推断: target->X, a->Y, b->Z
get_col_name <- function(name) {
  if (name == "target") return("X")
  if (name == "a") return("Y")
  if (name == "b") return("Z")
}

loop_pops <- get_pop(OUT_VAR) # 决定输出多少个文件
col_x <- get_col_name(X_AXIS)
col_y <- get_col_name(Y_AXIS)
col_loop <- get_col_name(OUT_VAR)

# 开始循环绘制
for (item in loop_pops) {
  # 筛选当前循环的数据
  f4 <- f4_score %>% filter(!!sym(col_loop) == item)
  
  # 转换为矩阵：根据配置选择 X轴变量和 Y轴变量
  # acast(data, formula) -> formula 左边是行(Y轴)，右边是列(X轴)
  formula_str <- paste0(col_y, " ~ ", col_x)
  f4_matrix <- acast(f4, as.formula(formula_str), value.var = "z-score", drop = F)
  
  # 转换为数值矩阵并过滤人群
  # 确保只包含配置文件中定义的人群，避免 acast 抓取了额外的群体
  rows_needed <- get_pop(Y_AXIS)
  cols_needed <- get_pop(X_AXIS)
  
  # 检查矩阵中是否存在对应的人群，防止下标越界
  rows_in_mat <- rows_needed[rows_needed %in% rownames(f4_matrix)]
  cols_in_mat <- cols_needed[cols_needed %in% colnames(f4_matrix)]
  
  if (length(rows_in_mat) < 2 || length(cols_in_mat) < 2) {
    message(paste("跳过", item, ": 可用数据不足以生成热图"))
    next
  }
  
  plot_mat <- f4_matrix[rows_in_mat, cols_in_mat, drop = F]
  plot_mat <- apply(plot_mat, c(1,2), as.numeric)
  
  # 计算颜色阈值
  m <- max(abs(plot_mat), na.rm = T)
  
  # 绘图参数设置
  main_title <- paste0("f4 (Mbuti, ", Y_AXIS, "; ", item, ", X)")
  
  if (m >= 3) {
    color_param <- colorRampPalette(c("navy", "white", "firebrick3"), alpha = T)(100)
    # 根据你的原逻辑，这里使用动态 breaks
    # 为了颜色平滑，建议使用 seq 而不是离散的 5 个点
    breaks_param <- seq(-m, m, length.out = 101)
  } else {
    color_param <- c("#6666B2FF", "#FFFFFF", "#E17C7CFF")
    breaks_param <- c(-3, -2, 2, 3)
  }
  
  # 保存 PDF
  file_name <- paste0("Heatmap_", OUT_VAR, "_", item, ".pdf")
  pdf(file_name, width = 40, height = 16)
  
  pheatmap(plot_mat,
           treeheight_col = 80, 
           fontsize = 15, 
           treeheight_row = 60,
           # cutree 参数如果人群太少会报错，增加判断
           cutree_rows = min(3, nrow(plot_mat)-1), 
           cutree_cols = min(5, ncol(plot_mat)-1),
           cellwidth = 30, 
           cellheight = 20,
           main = main_title,
           color = color_param,
           breaks = breaks_param,
           na_col = "grey90") # 加上缺失值颜色
  
  dev.off()
}