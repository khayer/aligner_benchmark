library(ggplot2)
library(tidyr)
library(scales)
library(dplyr)
setwd("~/github/aligner_benchmark/rscripts")

cols <- c('character','character','character','character','character','character',
          'numeric','character','character')
#d = read.csv("../test_file_anno", head =T,sep = "\t", colClasses = cols)
#test_file_anno_malaria
d = read.csv("~/Google Drive/AlignerBenchmarkLocal/summary_annotation.txt", head =T,sep = "\t", colClasses = cols)
d$annotation = sub("true", "with annotation", d$annotation)
d$annotation = sub("false", "without annotation", d$annotation)
d$algorithm = sub("_anno", "", d$algorithm)
d$annotation = factor(d$annotation, levels = c("without annotation","with annotation"))

# Plot the 100 plots
d$measurement[d$measurement == "aligned_correctly"] = "aligned correctly"
d$measurement[d$measurement == "aligned_ambiguously"] = "aligned ambiguously"
d$measurement[d$measurement == "aligned_incorrectly"] = "aligned incorrectly"
l  = spread(d[,c("level","algorithm","annotation","species","dataset",
                 "measurement","value")], measurement, value)

l$"aligned correctly" = 1-l$"aligned ambiguously"-l$unaligned-l$"aligned incorrectly"

l$"aligned correctly"[l$"aligned correctly" == 1] = NA
l$"aligned ambiguously"[is.na(l$"aligned correctly")] = NA
l$unaligned[is.na(l$unaligned)] = NA
l$"aligned incorrectly"[is.na(l$"aligned correctly")] = NA

gat = gather(l,measurement,value,-level, -algorithm, -annotation, -species, -dataset)
#cbPalette <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")
cbPalette <- c("#009E73", "#E69F00", "#CE3700", "#C0C0C0", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")
gat = gat[gat$measurement %in% c("aligned incorrectly","aligned ambiguously","unaligned","aligned correctly") ,]

gat$measurement = factor(gat$measurement, levels = c("aligned correctly","aligned ambiguously","aligned incorrectly","unaligned"))


plot_100_plot <- function(data,ylabs,titles,file) {
  ggplot(arrange(data, measurement), aes(x=annotation, y=value, fill=measurement, order = as.numeric(measurement))) + 
    geom_bar(stat="identity",width= .85) + 
    theme_gray(base_size=10) +#theme_light()+
    theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = .5),strip.text.x = element_text( angle = 90)) +
    facet_grid(. ~ algorithm) +
    #scale_y_continuous(limits=c(0.0,1),oob = rescale_none) + 
    ylab(ylabs) +  ggtitle(titles) + xlab("") +
    #scale_x_discrete(limits=data[order(data[data$measurement == "aligned correctly",]$value,decreasing = TRUE),]$algorithm) +
    scale_fill_manual(values=cbPalette) 
  ggsave(
    file,
    width = 7.75,
    height = 5.25,
    dpi = 300
  )
}

r = gat[ gat$level == "BASE" & gat$species == "human" & gat$dataset == "t3",]
plot_100_plot(r,"percent of total bases","Effect of annotation - human t3 base level","anno/human_t3_BASE.pdf")

r = gat[ gat$level == "BASE" & gat$species == "human" & gat$dataset == "t2",]
plot_100_plot(r,"percent of total bases","Effect of annotation - human t2 base level","anno/human_t2_BASE.pdf")

r = gat[ gat$level == "BASE" & gat$species == "human" & gat$dataset == "t1",]
plot_100_plot(r,"percent of total bases","Effect of annotation - human t1 base level","anno/human_t1_BASE.pdf")

r = gat[ gat$level == "READ" & gat$species == "human" & gat$dataset == "t3",]
plot_100_plot(r,"percent of total reads","Effect of annotation - human t3 read level","anno/human_t3_READ.pdf")

r = gat[ gat$level == "READ" & gat$species == "human" & gat$dataset == "t2",]
plot_100_plot(r,"percent of total reads","Effect of annotation - human t2 read level","anno/human_t2_READ.pdf")

r = gat[ gat$level == "READ" & gat$species == "human" & gat$dataset == "t1",]
plot_100_plot(r,"percent of total reads","Effect of annotation - human t1 read level","anno/human_t1_READ.pdf")


# Malaria
r = gat[ gat$level == "BASE" & gat$species == "malaria" & gat$dataset == "t3",]
plot_100_plot(r,"percent of total bases","Effect of annotation - malaria t3 base level","anno/malaria_t3_BASE.pdf")

r = gat[ gat$level == "BASE" & gat$species == "malaria" & gat$dataset == "t2",]
plot_100_plot(r,"percent of total bases","Effect of annotation - malaria t2 base level","anno/malaria_t2_BASE.pdf")

r = gat[ gat$level == "BASE" & gat$species == "malaria" & gat$dataset == "t1",]
plot_100_plot(r,"percent of total bases","Effect of annotation - malaria t1 base level","anno/malaria_t1_BASE.pdf")

r = gat[ gat$level == "READ" & gat$species == "malaria" & gat$dataset == "t3",]
plot_100_plot(r,"percent of total reads","Effect of annotation - malaria t3 read level","anno/malaria_t3_READ.pdf")

r = gat[ gat$level == "READ" & gat$species == "malaria" & gat$dataset == "t2",]
plot_100_plot(r,"percent of total reads","Effect of annotation - malaria t2 read level","anno/malaria_t2_READ.pdf")

r = gat[ gat$level == "READ" & gat$species == "malaria" & gat$dataset == "t1",]
plot_100_plot(r,"percent of total reads","Effect of annotation - malaria t1 read level","anno/malaria_t1_READ.pdf")



plot_recall <- function(data,ylabs,titles,file) {
  ggplot(data, aes(x=annotation, y=value, fill=measurement)) + 
    geom_bar(stat="identity",position="dodge",width= .85) + 
    theme_gray(base_size=10) +#theme_light()+
    theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = .5),strip.text.x = element_text( angle = 90)) +
    facet_grid(. ~ algorithm) +
    #scale_y_continuous(limits=c(0.0,1),oob = rescale_none) + 
    ylab(ylabs) +  ggtitle(titles) + xlab("") +
    #scale_x_discrete(limits=data[order(data[data$measurement == "aligned correctly",]$value,decreasing = TRUE),]$algorithm) +
    scale_fill_manual(values=cbPalette) 
  ggsave(
    file,
    width = 7.75,
    height = 5.25,
    dpi = 300
  )
}
l$recall[l$recall == 1] = NA
l$precision[l$precision == 1] = NA
gat = gather(l,measurement,value,-level, -algorithm, -annotation, -species, -dataset)
#cbPalette <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")
gat = gat[gat$measurement %in% c("recall","precision") ,]



r = gat[ gat$level == "JUNC" & gat$species == "malaria" & gat$dataset == "t3",]
plot_recall(r,"","Effect of annotation - malaria t3 junction level","anno/malaria_t3_JUNC.pdf")
r = gat[ gat$level == "JUNC" & gat$species == "malaria" & gat$dataset == "t2",]
plot_recall(r,"","Effect of annotation - malaria t2 junction level","anno/malaria_t2_JUNC.pdf")
r = gat[ gat$level == "JUNC" & gat$species == "malaria" & gat$dataset == "t1",]
plot_recall(r,"","Effect of annotation - malaria t1 junction level","anno/malaria_t1_JUNC.pdf")
r = gat[ gat$level == "JUNC" & gat$species == "human" & gat$dataset == "t3",]
plot_recall(r,"","Effect of annotation - human t3 junction level","anno/human_t3_JUNC.pdf")
r = gat[ gat$level == "JUNC" & gat$species == "human" & gat$dataset == "t2",]
plot_recall(r,"","Effect of annotation - human t2 junction level","anno/human_t2_JUNC.pdf")
r = gat[ gat$level == "JUNC" & gat$species == "human" & gat$dataset == "t1",]
plot_recall(r,"","Effect of annotation - human t1 junction level","anno/human_t1_JUNC.pdf")
