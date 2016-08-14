library(ggplot2)
library(tidyr)
library(scales)
library(dplyr)
setwd("~/github/aligner_benchmark/rscripts")

cols <- c('character','character','character','character','character','character',
          'numeric','character','character')
#d = read.csv("../test_file_anno", head =T,sep = "\t", colClasses = cols)
#test_file_anno_malaria
d = read.csv("~/Google Drive/AlignerBenchmarkLocal/versions/summary_versions.txt", head =T,sep = "\t", colClasses = cols)
#d$annotation = sub("true", "with annotation", d$annotation)
#d$annotation = sub("false", "without annotation", d$annotation)
#d$algorithm = sub("_anno", "", d$algorithm)
d$versions = factor(d$versions, levels = c("tested","latest"))

# Plot the 100 plots
d$measurement[d$measurement == "aligned_correctly"] = "aligned correctly"
d$measurement[d$measurement == "aligned_ambiguously"] = "aligned ambiguously"
d$measurement[d$measurement == "aligned_incorrectly"] = "aligned incorrectly"
l  = spread(d[,c("level","algorithm","versions","species","dataset",
                 "measurement","value")], measurement, value)

l$"aligned correctly" = 1-l$"aligned ambiguously"-l$unaligned-l$"aligned incorrectly"

l$"aligned correctly"[l$"aligned correctly" == 1] = NA
l$"aligned ambiguously"[is.na(l$"aligned correctly")] = NA
l$unaligned[is.na(l$unaligned)] = NA
l$"aligned incorrectly"[is.na(l$"aligned correctly")] = NA

gat = gather(l,measurement,value,-level, -algorithm, -versions, -species, -dataset)
#cbPalette <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")
cbPalette <- c("#009E73", "#E69F00", "#CE3700", "#C0C0C0", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")
gat = gat[gat$measurement %in% c("aligned incorrectly","aligned ambiguously","unaligned","aligned correctly") ,]

gat$measurement = factor(gat$measurement, levels = c("aligned correctly","aligned ambiguously","aligned incorrectly","unaligned"))


plot_100_plot <- function(data,ylabs,titles,file) {
  ggplot(arrange(data, measurement), aes(x=versions, y=value, fill=measurement, order = as.numeric(measurement))) + 
    geom_bar(stat="identity",width= .85) + 
    theme_gray(base_size=15) +#theme_light()+
    theme(axis.text.x = element_text(size=15, face ="bold", angle = 90, hjust = 1, vjust = .5),strip.text.x = element_text( angle = 90)) +
    facet_grid(. ~ algorithm) +
    #scale_y_continuous(limits=c(0.0,1),oob = rescale_none) + 
    ylab(ylabs) +  ggtitle(titles) + xlab("") +
    theme(strip.text.x = element_text(size = 15, colour = "black", angle = 90, face = "bold"))  +
    #scale_x_discrete(limits=data[order(data[data$measurement == "aligned correctly",]$value,decreasing = TRUE),]$algorithm) +
    scale_fill_manual(values=cbPalette) 
  ggsave(
    file,
    width = 8.75,
    height = 5.25,
    dpi = 300
  )
}

# HUMAN
r = gat[ gat$level == "BASELEVEL" & gat$species == "human" & gat$dataset == "T3",]
plot_100_plot(r,"percent of total bases","Versions - human t3 base level","versions/human_t3_BASE.pdf")

r = gat[ gat$level == "BASELEVEL" & gat$species == "human" & gat$dataset == "T2",]
plot_100_plot(r,"percent of total bases","Versions - human t2 base level","versions/human_t2_BASE.pdf")

r = gat[ gat$level == "BASELEVEL" & gat$species == "human" & gat$dataset == "T1",]
plot_100_plot(r,"percent of total bases","Versions - human t1 base level","versions/human_t1_BASE.pdf")

r = gat[ gat$level == "READLEVEL" & gat$species == "human" & gat$dataset == "T3",]
plot_100_plot(r,"percent of total bases","Versions - human t3 read level","versions/human_t3_READ.pdf")

r = gat[ gat$level == "READLEVEL" & gat$species == "human" & gat$dataset == "T2",]
plot_100_plot(r,"percent of total bases","Versions - human t2 read level","versions/human_t2_READ.pdf")

r = gat[ gat$level == "READLEVEL" & gat$species == "human" & gat$dataset == "T1",]
plot_100_plot(r,"percent of total bases","Versions - human t1 read level","versions/human_t1_READ.pdf")


# Malaria
r = gat[ gat$level == "BASELEVEL" & gat$species == "malaria" & gat$dataset == "T3",]
plot_100_plot(r,"percent of total bases","Versions - malaria t3 base level","versions/malaria_t3_BASE.pdf")

r = gat[ gat$level == "BASELEVEL" & gat$species == "malaria" & gat$dataset == "T2",]
plot_100_plot(r,"percent of total bases","Versions - malaria t2 base level","versions/malaria_t2_BASE.pdf")

r = gat[ gat$level == "BASELEVEL" & gat$species == "malaria" & gat$dataset == "T1",]
plot_100_plot(r,"percent of total bases","Versions - malaria t1 base level","versions/malaria_t1_BASE.pdf")

r = gat[ gat$level == "READLEVEL" & gat$species == "malaria" & gat$dataset == "T3",]
plot_100_plot(r,"percent of total bases","Versions - malaria t3 read level","versions/malaria_t3_READ.pdf")

r = gat[ gat$level == "READLEVEL" & gat$species == "malaria" & gat$dataset == "T2",]
plot_100_plot(r,"percent of total bases","Versions - malaria t2 read level","versions/malaria_t2_READ.pdf")

r = gat[ gat$level == "READLEVEL" & gat$species == "malaria" & gat$dataset == "T1",]
plot_100_plot(r,"percent of total bases","Versions - malaria t1 read level","versions/malaria_t1_READ.pdf")



plot_recall <- function(data,ylabs,titles,file) {
  ggplot(data, aes(x=versions, y=value, fill=measurement)) + 
    geom_bar(stat="identity",position="dodge",width= .85) + 
    theme_gray(base_size=15) +#theme_light()+
    theme(axis.text.x = element_text(size=15, face ="bold",angle = 90, hjust = 1, vjust = .5),strip.text.x = element_text( angle = 90)) +
    facet_grid(. ~ algorithm) +
    #scale_y_continuous(limits=c(0.0,1),oob = rescale_none) + 
    ylab(ylabs) +  ggtitle(titles) + xlab("") +
    theme(strip.text.x = element_text(size = 15, colour = "black", angle = 90, face = "bold"))  +
    #scale_x_discrete(limits=data[order(data[data$measurement == "aligned correctly",]$value,decreasing = TRUE),]$algorithm) +
    scale_fill_manual(values=cbPalette) 
  ggsave(
    file,
    width = 9.25,
    height = 6.75,
    dpi = 300
  )
}
l  = spread(d[,c("level","algorithm","versions","species","dataset",
                 "measurement","value")], measurement, value)
l$skipping_recall[l$skipping_recall == 1] = NA
l$skipping_precision[l$skipping_precision == 1] = NA
gat = gather(l,measurement,value,-level, -algorithm, -versions, -species, -dataset)
#cbPalette <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")
gat = gat[gat$measurement %in% c("skipping_recall","skipping_precision") ,]
gat = gat[ gat$level == "JUNCLEVEL",]
gat[gat$measurement  == "skipping_recall",]$measurement = "recall"
gat[gat$measurement  == "skipping_precision",]$measurement = "precision"


r = gat[ gat$level == "JUNCLEVEL" & gat$species == "malaria" & gat$dataset == "T3",]
plot_recall(r,"","Versions - malaria t3 junction level","versions/malaria_t3_JUNC.pdf")
r = gat[ gat$level == "JUNCLEVEL" & gat$species == "malaria" & gat$dataset == "T2",]
plot_recall(r,"","Versions - malaria t2 junction level","versions/malaria_t2_JUNC.pdf")
r = gat[ gat$level == "JUNCLEVEL" & gat$species == "malaria" & gat$dataset == "T1",]
plot_recall(r,"","Versions - malaria t1 junction level","versions/malaria_t1_JUNC.pdf")

r = gat[ gat$level == "JUNCLEVEL" & gat$species == "human" & gat$dataset == "T3",]
plot_recall(r,"","Versions - human t3 junction level","versions/human_t3_JUNC.pdf")
r = gat[ gat$level == "JUNCLEVEL" & gat$species == "human" & gat$dataset == "T2",]
plot_recall(r,"","Versions - human t2 junction level","versions/human_t2_JUNC.pdf")
r = gat[ gat$level == "JUNCLEVEL" & gat$species == "human" & gat$dataset == "T1",]
plot_recall(r,"","Versions - human t1 junction level","versions/human_t1_JUNC.pdf")

l  = spread(d[,c("level","algorithm","versions","species","dataset",
                 "measurement","value")], measurement, value)
gat = gather(l,measurement,value,-level, -algorithm, -versions, -species, -dataset)
gat = gat[gat$measurement %in% c("recall","precision") ,]

r = gat[ gat$level == "READLEVEL" & gat$species == "malaria" & gat$dataset == "T3",]
plot_recall(r,"","Versions - malaria t3 read level","versions/malaria_t3_READ_BAR.pdf")
r = gat[ gat$level == "READLEVEL" & gat$species == "malaria" & gat$dataset == "T2",]
plot_recall(r,"","Versions - malaria t2 read level","versions/malaria_t2_READ_BAR.pdf")
r = gat[ gat$level == "READLEVEL" & gat$species == "malaria" & gat$dataset == "T1",]
plot_recall(r,"","Versions - malaria t1 read level","versions/malaria_t1_READ_BAR.pdf")

r = gat[ gat$level == "READLEVEL" & gat$species == "human" & gat$dataset == "T3",]
plot_recall(r,"","Versions - human t3 read level","versions/human_t3_READ_BAR.pdf")
r = gat[ gat$level == "READLEVEL" & gat$species == "human" & gat$dataset == "T2",]
plot_recall(r,"","Versions - human t2 read level","versions/human_t2_READ_BAR.pdf")
r = gat[ gat$level == "READLEVEL" & gat$species == "human" & gat$dataset == "T1",]
plot_recall(r,"","Versions - human t1 read level","versions/human_t1_READ_BAR.pdf")

r = gat[ gat$level == "BASELEVEL" & gat$species == "malaria" & gat$dataset == "T3",]
plot_recall(r,"","Versions - malaria t3 base level","versions/malaria_t3_BASE_BAR.pdf")
r = gat[ gat$level == "BASELEVEL" & gat$species == "malaria" & gat$dataset == "T2",]
plot_recall(r,"","Versions - malaria t2 base level","versions/malaria_t2_BASE_BAR.pdf")
r = gat[ gat$level == "BASELEVEL" & gat$species == "malaria" & gat$dataset == "T1",]
plot_recall(r,"","Versions - malaria t1 base level","versions/malaria_t1_BASE_BAR.pdf")

r = gat[ gat$level == "BASELEVEL" & gat$species == "human" & gat$dataset == "T3",]
plot_recall(r,"","Versions - human t3 base level","versions/human_t3_BASE_BAR.pdf")
r = gat[ gat$level == "BASELEVEL" & gat$species == "human" & gat$dataset == "T2",]
plot_recall(r,"","Versions - human t2 base level","versions/human_t2_BASE_BAR.pdf")
r = gat[ gat$level == "BASELEVEL" & gat$species == "human" & gat$dataset == "T1",]
plot_recall(r,"","Versions - human t1 base level","versions/human_t1_BASE_BAR.pdf")
