library(ggplot2)
library(tidyverse)
library(ggtext)
library(ggmagnify)
library(ggpubr)
library(ggrepel)
library(dplyr)
library(patchwork)

# 26/07/09 只需要准备跑smartpca的poplist文件以及smartpca的结果文件evec/eval

default_pop_colors <- c(
  "#800000",
  "#808000",
  "#FFE4C4",
  "#FFE119",
  "#E6BEFF",
  "#FABEBE",
  "#46F0F0",
  "#BCF60C",
  "#F032E6",
  "#F57C7C",
  "#9D7BBA",
  "#000099",
  "#B15928",
  "#FBB268",
  "#00FA9A",
  "#0080FF",
  "#3CB371",
  "#C0C0C0"
)

parse_poplist_groups <- function(poplist_file,
                                 modern = TRUE,
                                 color_palette = default_pop_colors,
                                 modern_gray = "#C0C0C0") {
  poplist_lines <- readLines(poplist_file, warn = FALSE)
  poplist_lines <- trimws(poplist_lines)
  poplist_lines <- poplist_lines[poplist_lines != ""]

  if (length(poplist_lines) == 0) {
    stop("poplist文件为空")
  }

  header_index <- grepl("^=+.*=+$", poplist_lines)
  if (!any(header_index)) {
    stop("poplist文件中没有找到形如 ====XXX==== 的分组标签")
  }

  groups <- list()
  current_group <- NULL
  for (line in poplist_lines) {
    if (grepl("^=+.*=+$", line)) {
      current_group <- sub("^=+\\s*(.*?)\\s*=+$", "\\1", line)
      groups[[current_group]] <- character(0)
    } else if (!is.null(current_group)) {
      groups[[current_group]] <- c(groups[[current_group]], line)
    }
  }

  groups <- groups[lengths(groups) > 0]
  if (length(groups) == 0) {
    stop("poplist文件中没有可用的人群名称")
  }

  rows <- list()
  color_i <- 1
  for (group_name in names(groups)) {
    group_type <- if (grepl("^ancient", group_name, ignore.case = TRUE)) {
      "ancient"
    } else if (tolower(group_name) == "target") {
      "Target"
    } else {
      "modern"
    }

    group_color <- if (group_type == "Target") {
      "#FF0000"
    } else if (group_name %in% names(color_palette)) {
      color_palette[[group_name]]
    } else {
      unname(color_palette[((color_i - 1) %% length(color_palette)) + 1])
    }

    if (group_type != "Target") {
      color_i <- color_i + 1
    }

    point_color <- if (!modern && group_type == "modern") modern_gray else group_color

    rows[[length(rows) + 1]] <- data.frame(
      Pop = group_name,
      col = "#FFFFFF",
      popgroup = "Label",
      m_or_a = "Label",
      stringsAsFactors = FALSE
    )

    rows[[length(rows) + 1]] <- data.frame(
      Pop = groups[[group_name]],
      col = point_color,
      popgroup = group_name,
      m_or_a = group_type,
      stringsAsFactors = FALSE
    )
  }

  do.call(rbind, rows)
}

#' 生成PCA绘图
#'
#' @param input_prefix 输入文件前缀
#' @param pop_color_file 种群颜色分组文件路径；为空时使用poplist_file自动生成
#' @param poplist_file smartpca使用的poplist.txt路径
#' @param modern 是否将现代人群展示为不同颜色；FALSE时现代人群统一为灰色#C0C0C0，古代人群颜色不受影响
#' @param target_pops 目标种群名称向量
#' @param target_plot_pops 指定需要可视化的Target人群；NULL表示展示所有Target人群，指定后样式仍按完整Target列表分配
#' @param plot_popgroups 指定需要显示的小标签分组（poplist中的====XXX====）；NULL表示展示所有小标签分组
#' @param output_prefix 输出文件前缀
#' @param plot_width 图形宽度
#' @param plot_height 图形高度
#' @param legend_width 图例宽度
#' @param legend_height 图例高度
#' @param show_legend 是否显示图例
#' @param point_size 点大小
#' @param point_stroke 点边框宽度
#' @param legend_cols 图例列数
#' @param axis_text_size 坐标轴文字大小
#' @param axis_title_size 坐标轴标题大小
#' @param legend_text_size 图例文字大小
#' @param pc_x 用于x轴的主成分（默认为PC1）
#' @param pc_y 用于y轴的主成分（默认为PC2）
#'
#' @return 无返回值，直接保存图形文件
#'
#' @examples
#' pca_plot(
#'   input_prefix="smartpca_0222",
#'   pop_color_file = "PCAplot_popgroup_color.csv",
#'   target_pops = c("XJCDM_Han_Dynasty", "XJCDM_Han_Dynasty_o1", "ZHM_Han_Dynasty"),
#'   output_prefix = "PCA_xjcd"
#' )
pca_plot <- function(
    input_prefix,
    pop_color_file = NULL,
    poplist_file = "poplist.txt",
    modern = TRUE,
    target_pops=c(),
    target_plot_pops = NULL,
    plot_popgroups = NULL,
    output_prefix = "PCAplot",
    plot_width = 48,
    plot_height = 35,
    legend_width = 40,
    legend_height = 18,
    show_legend = FALSE,
    point_size = 12,
    point_stroke = 3.6,
    legend_cols = 8,
    axis_text_size = 50,
    axis_title_size = 50,
    legend_text_size = 32,
    pc_x = "PC1",
    pc_y = "PC2") {
  
  evec_file <- paste0(input_prefix,'.evec')
  eval_file <- paste0(input_prefix,'.eval')
  # 读取evec文件并动态设置列名
  evec_data_raw <- read.table(evec_file, stringsAsFactors = FALSE)
  
  # 确定列数并设置列名
  n_cols <- ncol(evec_data_raw)
  if (n_cols < 3) {
    stop("evec文件至少需要3列：样本名、至少1个主成分、群体标签")
  }
  
  # 构建列名：第一列是Sample，最后1列是Pop，中间是PC1, PC2, ...
  col_names <- c("Sample", paste0("PC", 1:(n_cols-2)), "Pop")
  names(evec_data_raw) <- col_names
  
  evecDat <- evec_data_raw
  
  # 读取其他数据
  evalDat <- read.table(eval_file)
  if (!is.null(pop_color_file) && file.exists(pop_color_file)) {
    popGroups <- read.csv(pop_color_file, header = FALSE, col.names = c("Pop", "col", "popgroup", "m_or_a"))
    if (!modern) {
      popGroups$col[popGroups$m_or_a == "modern"] <- "#C0C0C0"
    }
  } else {
    if (is.null(poplist_file) || !file.exists(poplist_file)) {
      stop("未找到pop_color_file或poplist_file，请提供已有CSV或smartpca的poplist.txt")
    }
    popGroups <- parse_poplist_groups(poplist_file = poplist_file, modern = modern)
  }
  
  # 计算主成分百分比
  evalDat$por <- evalDat$V1 / sum(evalDat$V1) * 100
  
  # 动态生成label数据
  label_pops <- c(popGroups[popGroups$popgroup == "Label", "Pop"])
  if (length(target_pops)>0) {
    label_pops <- c(label_pops,'Target')
  }
  label_data <- do.call(rbind, lapply(label_pops, function(pop) {
    pc_cols <- setdiff(names(evecDat), c("Sample", "Pop"))
    zeros <- rep(0, length(pc_cols))
    label_row <- data.frame(Sample = "label", t(zeros), Pop = pop, stringsAsFactors = FALSE)
    names(label_row) <- c("Sample", pc_cols, "Pop")
    label_row
  }))
  
  # label_data转换数值列
  numeric_cols <- setdiff(names(evecDat), c("Sample", "Pop"))
  for (col in numeric_cols) {
    label_data[[col]] <- as.numeric(label_data[[col]])
    evecDat[[col]] <- as.numeric(evecDat[[col]])
  }
  
  # 合并label数据和原始数据
  evecDat <- rbind(label_data, evecDat)
  
  # 处理popGroups数据
  popGroups$fill <- "#FFFF00"
  popGroups$symbol <- 0
  
  # 为popGroups生成symbol编号
  for (i in 2:nrow(popGroups)) {
    if (popGroups[i, "popgroup"] == popGroups[i-1, "popgroup"]) {
      popGroups[i, "symbol"] <- popGroups[i-1, "symbol"] + 1
    } else {
      popGroups[i, "symbol"] <- 0
    }
  }
  
  poplist_target_count <- sum(popGroups$m_or_a == "Target")
  if (poplist_target_count > 0 && poplist_target_count < 5) {
    popGroups$symbol[popGroups$m_or_a == "Target"] <- seq(21, 21 + poplist_target_count - 1)
    popGroups$fill[popGroups$m_or_a == "Target"] <- "#FFFF00"
  }

  if (length(target_pops)>0) {
    if (length(target_pops) < 5) {
      target_symbols <- c(0, seq(21, 21 + length(target_pops) - 1))
      target_fill <- rep("#FFFF00", length(target_pops) + 1)
    } else {
      target_symbols <- c(0, seq(0, length(target_pops) - 1))
      target_fill <- rep("#F00000", length(target_pops) + 1)
    }

    # 添加目标人群到popGroups
    target_rows <- data.frame(
      Pop = c("Target", target_pops),
      col = c("#FFFFFF", rep("#FF0000", length(target_pops))),
      popgroup = c("Label", rep("Target", length(target_pops))),
      m_or_a = c("Label", rep("Target", length(target_pops))),
      fill = target_fill,
      #symbol = c(0,8)
      symbol = target_symbols
    )
    popGroups <- rbind(popGroups, target_rows)
    popGroups$symbol <- as.numeric(popGroups$symbol)
  }

  if (!is.null(target_plot_pops)) {
    target_plot_pops <- as.character(target_plot_pops)
    available_target_pops <- popGroups$Pop[popGroups$m_or_a == "Target"]
    missing_target_pops <- setdiff(target_plot_pops, available_target_pops)
    if (length(missing_target_pops) > 0) {
      warning(paste0("以下target_plot_pops不在Target列表中，将被忽略：", paste(missing_target_pops, collapse = ", ")))
    }
    popGroups <- popGroups[popGroups$m_or_a != "Target" | popGroups$Pop %in% target_plot_pops, ]
  }

  if (!is.null(plot_popgroups)) {
    plot_popgroups <- as.character(plot_popgroups)
    available_popgroups <- unique(popGroups$popgroup[popGroups$m_or_a != "Target" & popGroups$popgroup != "Label"])
    missing_popgroups <- setdiff(plot_popgroups, available_popgroups)
    if (length(missing_popgroups) > 0) {
      warning(paste0("以下plot_popgroups不在小标签分组中，将被忽略：", paste(missing_popgroups, collapse = ", ")))
    }
    popGroups <- popGroups[
      popGroups$m_or_a == "Target" |
        (popGroups$popgroup == "Label" & popGroups$Pop %in% c(plot_popgroups, "Target")) |
        popGroups$popgroup %in% plot_popgroups,
    ]
  }
  
  # 合并数据
  mergedEvecDat <- merge(evecDat, popGroups, by = "Pop")
  # 手动去掉一些离群个体
  #mergedEvecDat <- mergedEvecDat[!mergedEvecDat$Sample %in% c('XHTB17.HO'),]
  
  # 按类别重新排序数据
  label_data <- mergedEvecDat[mergedEvecDat$m_or_a == "Label", ]
  ancient_data <- mergedEvecDat[mergedEvecDat$m_or_a == "ancient", ]
  modern_data <- mergedEvecDat[mergedEvecDat$m_or_a == "modern", ]
  target_data <- mergedEvecDat[mergedEvecDat$m_or_a == "Target", ]
  
  mergedEvecDat <- rbind(label_data, modern_data, ancient_data, target_data)
  
  # 创建图例文本格式
  create_legend_text <- function(text, category) {
    ifelse(category == "Label",
           sprintf("<b>%s</b>", text),
           text)
  }
  
  mergedEvecDat$Pop <- mapply(create_legend_text, mergedEvecDat$Pop, mergedEvecDat$popgroup)
  popGroups$Pop <- mapply(create_legend_text, popGroups$Pop, popGroups$popgroup)
  
  # 添加注释
  mergedEvecDat <- mergedEvecDat %>%
    mutate(annot = ifelse(popgroup == "Target", Sample, ''))
  
  # 设置因子水平
  v1 <- factor(mergedEvecDat$Pop, levels = popGroups$Pop)
  
  # 获取主成分的索引用于轴标签
  pc_x_index <- which(names(evecDat) == pc_x)
  pc_y_index <- which(names(evecDat) == pc_y)
  
  if (length(pc_x_index) == 0 || length(pc_y_index) == 0) {
    stop("指定的主成分名称不存在于数据中")
  }
  
  # 创建主图
  p <- ggplot(mergedEvecDat, aes_string(x = pc_x, y = pc_y, color = "v1", shape = "v1", fill = "v1")) +
    geom_point(size = point_size, stroke = point_stroke) +
    scale_shape_manual(
      name = "",
      labels = popGroups$Pop,
      values = popGroups$symbol
    ) +
    scale_color_manual(
      name = "",
      labels = popGroups$Pop,
      values = popGroups$col
    ) +
    scale_fill_manual(
      name = "",
      labels = popGroups$Pop,
      values = popGroups$fill
    ) +
    guides(
      shape = guide_legend(ncol = legend_cols),
      color = guide_legend(ncol = legend_cols),
      fill = guide_legend(ncol = legend_cols)
    ) +
    theme_classic() +
    theme(
      legend.background = element_rect(colour = "white"),
      legend.position = ifelse(show_legend, "right", "none"),
      legend.text = element_markdown(size = legend_text_size),
      axis.text.x = element_text(size = axis_text_size),
      axis.text.y = element_text(size = axis_text_size),
      axis.title.x = element_text(size = axis_title_size, face = 'bold'),
      axis.title.y = element_text(size = axis_title_size, face = 'bold'),
      panel.border = element_rect(fill = NA, color = "black", linewidth = 3, linetype = "solid"),
      plot.margin = unit(c(2, 2, 2, 2), "cm")
    ) +
    xlab(paste0(pc_x, " (", round(evalDat$por[pc_x_index - 1], 2), "%)")) +
    ylab(paste0(pc_y, " (", round(evalDat$por[pc_y_index - 1], 2), "%)"))
  
  # 创建图例图
  p_leg <- ggplot(mergedEvecDat, aes_string(x = pc_x, y = pc_y, color = "v1", shape = "v1", fill = "v1")) +
    geom_point(size = point_size / 2, stroke = point_stroke / 1.3) +
    scale_shape_manual(
      name = "",
      labels = popGroups$Pop,
      values = popGroups$symbol
    ) +
    scale_color_manual(
      name = "",
      labels = popGroups$Pop,
      values = popGroups$col
    ) +
    scale_fill_manual(
      name = "",
      labels = popGroups$Pop,
      values = popGroups$fill
    ) +
    guides(
      shape = guide_legend(ncol = legend_cols),
      color = guide_legend(ncol = legend_cols),
      fill = guide_legend(ncol = legend_cols)
    ) +
    theme_classic() +
    theme(
      legend.background = element_rect(colour = "black", linewidth = 2),
      legend.position = "right",
      legend.text = element_markdown(size = legend_text_size),
      legend.key.height = unit(1.2, "cm"),
      legend.key.width = unit(2.4, "cm")
    )
  
  # 提取图例
  leg <- get_legend(p_leg)
  legend_plot <- as_ggplot(leg)
  
  # 组合图形
  combined_plot <- p / legend_plot +
    plot_layout(nrow = 2, heights = c(2.5, 1))
  
  # 保存图形
  ggsave(paste0(output_prefix, ".pdf"), combined_plot, width = plot_width, height = plot_height)
  ggsave(paste0(output_prefix, "_main.pdf"), p, width = plot_width, height = plot_height)
  ggsave(paste0(output_prefix, "_legend.pdf"), legend_plot, width = legend_width, height = legend_height)
  
  message("PCA绘图完成！")
  message("生成文件:")
  message(paste0("- ", output_prefix, ".pdf"))
  message(paste0("- ", output_prefix, "_main.pdf"))
  message(paste0("- ", output_prefix, "_legend.pdf"))
  
  # 返回mergedEvecDat和popGroups两个数据框
  result_list <- list(
    mergedEvecDat = mergedEvecDat,
    popGroups = popGroups
  )
  
  return(result_list)
}

# 使用示例
# setwd("E:/Rworking/popgenetics/1project/smartpca/")
# 查看evec的rawdata
# evec_data_raw <- read.table(evec_file, stringsAsFactors = FALSE)
#
# 
# pca_plot(
#   input_prefix = "smartpca_v2",
#   poplist_file = "poplist.txt",
#   modern = TRUE,
#   output_prefix = "PCAplot"
# )
# 
# pca_plot(
#   input_prefix = "smartpca_v2",
#   poplist_file = "poplist.txt",
#   target_plot_pops = c("Bai_Dali", "Lama_Nujiang"),
#   plot_popgroups = c("Han", "ancientYR"),
#   output_prefix = "PCA_subset"
# )