library(ggplot2)
library(tidyr)
library(dplyr)
setwd("~/github/aligner_benchmark/rscripts/")
cbPalette <- c("#009E73", "#E69F00", "#CE3700", "#C0C0C0", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")


#plot_100_plot <- function(data,ylabs,titles,file) {
#  ggplot(data, aes(x=algorithm, y=value, fill=measurement, order = as.numeric(measurement))) + 
#    geom_bar(stat="identity",width= .9) + 
#    theme_gray(base_size=10) +#theme_light()+
#    theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = .5)) +
#    ylab(ylabs) +  ggtitle(titles) +
#    #scale_x_discrete(limits=data[order(data[data$measurement == "aligned correctly",]$mean,decreasing = TRUE),]$algorithm) +
#    scale_fill_manual(values=cbPalette) 
#  ggsave(
#    file,
#    width = 6.25,
#    height = 5.25,
#    dpi = 300
#  )
#}


plot_100_plot <- function(data,ylabs,titles,file) {
  ggplot(arrange(data, measurement), aes(x=annotation, y=value, fill=measurement)) + 
    geom_bar(stat="identity",width= .9) + 
    theme_gray(base_size=15) +#theme_light()+
    theme(axis.text.x = element_text(size=15, face ="bold", angle = 90, hjust = 1, vjust = .5),strip.text.x = element_text( angle = 90)) +
    facet_grid(anchor_length ~ algorithm) +
    ylab(ylabs) +  ggtitle(titles) + xlab("") +
    theme(strip.text.x = element_text(size = 15, colour = "black", angle = 90, face = "bold"))  +
    #scale_x_discrete(limits=data[order(data[data$measurement == "aligned correctly",]$mean,decreasing = TRUE),]$algorithm) +
    scale_fill_manual(values=cbPalette) 
  ggsave(
    file,
    width = 9.25,
    height = 8.75,
    dpi = 300
  )
}

plot_recall <- function(data,ylabs,titles,file) {
  ggplot(data, aes(x=annotation, y=value, fill=measurement)) + 
    geom_bar(stat="identity",position="dodge",width= .85) + 
    theme_gray(base_size=15) +#theme_light()+
    theme(axis.text.x = element_text(size=15, face ="bold",angle = 90, hjust = 1, vjust = .5),strip.text.x = element_text( angle = 90)) +
    facet_grid(anchor_length ~ algorithm) +
    #scale_y_continuous(limits=c(0.0,1),oob = rescale_none) + 
    ylab(ylabs) +  ggtitle(titles) + xlab("") +
    theme(strip.text.x = element_text(size = 15, colour = "black", angle = 90, face = "bold"))  +
    
    #scale_x_discrete(limits=data[order(data[data$measurement == "aligned correctly",]$value,decreasing = TRUE),]$algorithm) +
    scale_fill_manual(values=cbPalette) 
  ggsave(
    file,
    width = 9.25,
    height = 8.75,
    dpi = 300
  )
}

# READ_LEVEL
cols <- c('character','character','character','character','character','character','numeric','character','character')
d = read.csv("/Users/hayerk/Google Drive/AlignerBenchmarkLocal/splicing_signal/summary_splicing_signal.txt", head =T,sep = "\t", colClasses = cols)
d$anchor_length[d$anchor_length == "0"] = "non-canonical"
d$anchor_length[d$anchor_length == "1"] = "canonical"
d$anchor_length = factor(d$anchor_length)
d$algorithm = gsub("annotation*","",d$algorithm)
d$annotation[d$annotation == "true"] = "with annotation"
d$annotation[d$annotation == "false"] = "without annotation"
d$annotation = factor(d$annotation, levels = c("without annotation","with annotation"))

# Plot the 100 plots
d$measurement[d$measurement == "aligned_correctly"] = "aligned correctly"
d$measurement[d$measurement == "aligned_ambiguously"] = "aligned ambiguously"
d$measurement[d$measurement == "aligned_incorrectly"] = "aligned incorrectly"
l  = spread(d[,c("level","algorithm","annotation","anchor_length",
                 "measurement","value")], measurement, value)
l$"aligned correctly" = 1-l$"aligned ambiguously"-l$unaligned-l$"aligned incorrectly"
l$"aligned correctly"[l$"aligned correctly" == 1] = NA
l$"aligned ambiguously"[is.na(l$"aligned correctly")] = NA
l$unaligned[is.na(l$unaligned)] = NA
l$"aligned incorrectly"[is.na(l$"aligned correctly")] = NA
gat = gather(l,measurement,value, -level, -algorithm,-annotation,-anchor_length)
gat = gat[gat$measurement %in% c("aligned incorrectly","aligned ambiguously","unaligned","aligned correctly") ,]
gat$measurement = factor(gat$measurement, levels = c("aligned correctly","aligned ambiguously","aligned incorrectly","unaligned"))
r = gat[gat$level == "READLEVEL",]
plot_100_plot(r,"percent of total reads","Effect of splice signal - human t1 read level","canonical/canonical_READ.pdf")
r = gat[gat$level == "BASELEVEL",]
plot_100_plot(r,"percent of total bases","Effect of splice signal - human t1 base level","canonical/canonical_BASE.pdf")

gat = gather(l,measurement,value,-level, -algorithm,-annotation,-anchor_length)
gat = gat[gat$measurement %in% c("recall","precision") ,]
r = gat[ gat$level == "READLEVEL" ,]
plot_recall(r,"","Effect of splice signal - human t1 read level","canonical/canonical_READ_bar.pdf")
r = gat[ gat$level == "BASELEVEL" ,]
plot_recall(r,"","Effect of splice signal - human t1 base level","canonical/canonical_BASE_bar.pdf")

l  = spread(d[,c("level","algorithm","annotation","anchor_length",
                 "measurement","value")], measurement, value)
l$skipping_recall[l$skipping_recall == 1] = NA
l$skipping_precision[l$skipping_precision == 1] = NA
gat = gather(l,measurement,value,-level, -algorithm,-annotation,-anchor_length)
gat = gat[gat$measurement %in% c("skipping_recall","skipping_precision") ,]
r = gat[ gat$level == "JUNCLEVEL" ,]

r$measurement[r$measurement =="skipping_recall" ] = "recall"
r$measurement[r$measurement =="skipping_precision" ] = "precision"
plot_recall(r,"","Effect of splice signal - human t1 junction level","canonical/canonical_JUNC_bar.pdf")


