#!

args = commandArgs(trailingOnly = TRUE)
fn <- args[1]
pop <- args[2]

source("plotting_funcs.R")
plot_tree(fn, output_file=paste0(fn,".pdf"))

#改图片大小在144行
#改PDF长宽在295行

#residuals
plot_resid(stem=fn, pop_order=pop)
