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
  ggplot(arrange(data, measurement), aes(x=trimmed, y=value, fill=measurement)) + 
    geom_bar(stat="identity",width= .9) + 
    theme_gray(base_size=15) +#theme_light()+
    theme(axis.text.x = element_text(size=15, face ="bold", angle = 90, hjust = 1, vjust = .5),strip.text.x = element_text( angle = 90)) +
    facet_grid(adapter_length ~ algorithm) +
    ylab(ylabs) +  ggtitle(titles) + xlab("") +
    theme(strip.text.x = element_text(size = 15, colour = "black", angle = 90, face = "bold"))  +
    #scale_x_discrete(limits=data[order(data[data$measurement == "aligned correctly",]$mean,decreasing = TRUE),]$algorithm) +
    scale_fill_manual(values=cbPalette) 
  ggsave(
    file,
    width = 9.25,
    height = 15.75,
    dpi = 300
  )
}

plot_recall <- function(data,ylabs,titles,file) {
  ggplot(data, aes(x=trimmed, y=value, fill=measurement)) + 
    geom_bar(stat="identity",position="dodge",width= .85) + 
    theme_gray(base_size=15) +#theme_light()+
    theme(axis.text.x = element_text(size=15, face ="bold",angle = 90, hjust = 1, vjust = .5),strip.text.x = element_text( angle = 90)) +
    facet_grid(adapter_length ~ algorithm) +
    #scale_y_continuous(limits=c(0.0,1),oob = rescale_none) + 
    ylab(ylabs) +  ggtitle(titles) + xlab("") +
    theme(strip.text.x = element_text(size = 15, colour = "black", angle = 90, face = "bold"))  +
    
    #scale_x_discrete(limits=data[order(data[data$measurement == "aligned correctly",]$value,decreasing = TRUE),]$algorithm) +
    scale_fill_manual(values=cbPalette) 
  ggsave(
    file,
    width = 9.25,
    height = 15.75,
    dpi = 300
  )
}

## MALARIA 1st
# READ_LEVEL
cols <- c('character','character','character','character','character','character','numeric','character','character')
d = read.csv("/Users/hayerk/Google Drive/AlignerBenchmarkLocal/adapter/summary_adapter.txt", head =T,sep = "\t", colClasses = cols)
d$adapter_length = factor(d$adapter_length)
# Plot the 100 plots
d$measurement[d$measurement == "aligned_correctly"] = "aligned correctly"
d$measurement[d$measurement == "aligned_ambiguously"] = "aligned ambiguously"
d$measurement[d$measurement == "aligned_incorrectly"] = "aligned incorrectly"
l  = spread(d[,c("level","algorithm","trimmed","adapter_length",
                 "measurement","value")], measurement, value)
l$"aligned correctly" = 1-l$"aligned ambiguously"-l$unaligned-l$"aligned incorrectly"
gat = gather(l,measurement,value, -level, -algorithm,-trimmed,-adapter_length)
gat = gat[gat$measurement %in% c("aligned incorrectly","aligned ambiguously","unaligned","aligned correctly") ,]
gat$measurement = factor(gat$measurement, levels = c("aligned correctly","aligned ambiguously","aligned incorrectly","unaligned"))
r = gat[gat$level == "READLEVEL",]
plot_100_plot(r,"percent of total reads","Effect of adapters - human t1 read level","adapter/adapter_READ.pdf")
r = gat[gat$level == "BASELEVEL",]
plot_100_plot(r,"percent of total bases","Effect of adapters - human t1 base level","adapter/adapter_BASE.pdf")

gat = gather(l,measurement,value,-level, -algorithm,-trimmed,-adapter_length)
gat = gat[gat$measurement %in% c("recall","precision") ,]
r = gat[ gat$level == "READLEVEL" ,]
plot_recall(r,"","Effect of adapters - human t1 read level","adapter/adapter_READ_bar.pdf")
r = gat[ gat$level == "BASELEVEL" ,]
plot_recall(r,"","Effect of adapters - human t1 base level","adapter/adapter_BASE_bar.pdf")

