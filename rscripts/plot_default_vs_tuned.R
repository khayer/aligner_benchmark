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
  ggplot(arrange(data, measurement), aes(x=tuned, y=value, fill=measurement)) + 
    geom_bar(stat="identity",width= .9) + 
    theme_gray(base_size=15) +#theme_light()+
    theme(axis.text.x = element_text(size=15, face ="bold", angle = 90, hjust = 1, vjust = .5),strip.text.x = element_text( angle = 90)) +
    facet_grid(. ~ algorithm) +
    ylab(ylabs) +  ggtitle(titles) + xlab("") +
    theme(strip.text.x = element_text(size = 15, colour = "black", angle = 90, face = "bold"))  +
    #scale_x_discrete(limits=data[order(data[data$measurement == "aligned correctly",]$mean,decreasing = TRUE),]$algorithm) +
    scale_fill_manual(values=cbPalette) 
  ggsave(
    file,
    width = 9.25,
    height = 6.75,
    dpi = 300
  )
}

plot_recall <- function(data,ylabs,titles,file) {
  ggplot(data, aes(x=tuned, y=value, fill=measurement)) + 
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

## MALARIA 1st
# READ_LEVEL
cols <- c('character','character','character','character','character','character','numeric','character','character')
d = read.csv("/Users/hayerk/Google Drive/AlignerBenchmarkLocal/tuning/summary_malaria_t3r1_read_level_recall.txt", head =T,sep = "\t", colClasses = cols)
d$algorithm = sub(" tuned", "", d$algorithm)

# Plot the 100 plots
d$measurement[d$measurement == "aligned_correctly"] = "aligned correctly"
d$measurement[d$measurement == "aligned_ambiguously"] = "aligned ambiguously"
d$measurement[d$measurement == "aligned_incorrectly"] = "aligned incorrectly"
l  = spread(d[,c("level","algorithm","tuned",
                 "measurement","value")], measurement, value)
l$"aligned correctly" = 1-l$"aligned ambiguously"-l$unaligned-l$"aligned incorrectly"
gat = gather(l,measurement,value, -level, -algorithm,-tuned)
gat = gat[gat$measurement %in% c("aligned incorrectly","aligned ambiguously","unaligned","aligned correctly") ,]
gat$measurement = factor(gat$measurement, levels = c("aligned correctly","aligned ambiguously","aligned incorrectly","unaligned"))
r = gat[gat$level == "READLEVEL",]
plot_100_plot(r,"percent of total reads","Effect of tuning - malaria t3 read level","default_vs_tuned/malaria_t3_READ.pdf")
gat = gather(l,measurement,value,-level, -algorithm, -tuned)
gat = gat[gat$measurement %in% c("recall","precision") ,]
r = gat[ gat$level == "READLEVEL" ,]
plot_recall(r,"","Effect of tuning - malaria t3 read level","default_vs_tuned/malaria_t3_READ_bar.pdf")


# BASE_LEVEL
cols <- c('character','character','character','character','character','character','numeric','character','character')
d = read.csv("/Users/hayerk/Google Drive/AlignerBenchmarkLocal/tuning/summary_malaria_t3r1_base_level_recall.txt", head =T,sep = "\t", colClasses = cols)
d$algorithm = sub(" tuned", "", d$algorithm)

# Plot the 100 plots
d$measurement[d$measurement == "aligned_correctly"] = "aligned correctly"
d$measurement[d$measurement == "aligned_ambiguously"] = "aligned ambiguously"
d$measurement[d$measurement == "aligned_incorrectly"] = "aligned incorrectly"
l  = spread(d[,c("level","algorithm","tuned",
                 "measurement","value")], measurement, value)
l$"aligned correctly" = 1-l$"aligned ambiguously"-l$unaligned-l$"aligned incorrectly"
gat = gather(l,measurement,value, -level, -algorithm,-tuned)
gat = gat[gat$measurement %in% c("aligned incorrectly","aligned ambiguously","unaligned","aligned correctly") ,]
gat$measurement = factor(gat$measurement, levels = c("aligned correctly","aligned ambiguously","aligned incorrectly","unaligned"))
r = gat[gat$level == "BASELEVEL",]
plot_100_plot(r,"percent of total bases","Effect of tuning - malaria t3 base level","default_vs_tuned/malaria_t3_BASE.pdf")
gat = gather(l,measurement,value,-level, -algorithm, -tuned)
gat = gat[gat$measurement %in% c("recall","precision") ,]
r = gat[ gat$level == "BASELEVEL" ,]
plot_recall(r,"","Effect of tuning - malaria t3 base level","default_vs_tuned/malaria_t3_BASE_bar.pdf")


# JUNC_LEVEL
cols <- c('character','character','character','character','character','character','numeric','character','character')
d = read.csv("/Users/hayerk/Google Drive/AlignerBenchmarkLocal/tuning/summary_malaria_t3r1_junction_level_recall.txt", head =T,sep = "\t", colClasses = cols)
d$algorithm = sub(" tuned", "", d$algorithm)
# Plot the 100 plots
d=d[d$level == "JUNCLEVEL",]
d = d[!duplicated(d), ]
d$measurement[d$measurement =="skipping_recall"] = "recall"
d$measurement[d$measurement =="skipping_precision"] = "precision"
l  = spread(d[,c("level","algorithm","tuned",
                 "measurement","value")], measurement, value)

l$recall[l$recall == 1] = NA
l$precision[l$precision == 1] = NA
gat = gather(l,measurement,value,-level, -algorithm, -tuned)
gat = gat[gat$measurement %in% c("recall","precision") ,]
r = gat[ gat$level == "JUNCLEVEL" ,]
plot_recall(r,"","Effect of tuning - malaria t3 junction level","default_vs_tuned/malaria_t3_JUNC.pdf")




## HUMAN 1st
# READ_LEVEL
cols <- c('character','character','character','character','character','character','numeric','character','character')
d = read.csv("/Users/hayerk/Google Drive/AlignerBenchmarkLocal/tuning/summary_human_t3r1_read_level_recall.txt", head =T,sep = "\t", colClasses = cols)
d$algorithm = sub(" tuned", "", d$algorithm)

# Plot the 100 plots
d$measurement[d$measurement == "aligned_correctly"] = "aligned correctly"
d$measurement[d$measurement == "aligned_ambiguously"] = "aligned ambiguously"
d$measurement[d$measurement == "aligned_incorrectly"] = "aligned incorrectly"
l  = spread(d[,c("level","algorithm","tuned",
                 "measurement","value")], measurement, value)
l$"aligned correctly" = 1-l$"aligned ambiguously"-l$unaligned-l$"aligned incorrectly"
gat = gather(l,measurement,value, -level, -algorithm,-tuned)
gat = gat[gat$measurement %in% c("aligned incorrectly","aligned ambiguously","unaligned","aligned correctly") ,]
gat$measurement = factor(gat$measurement, levels = c("aligned correctly","aligned ambiguously","aligned incorrectly","unaligned"))
r = gat[gat$level == "READLEVEL",]
plot_100_plot(r,"percent of total reads","Effect of tuning - human t3 base level","default_vs_tuned/human_t3_READ.pdf")
gat = gather(l,measurement,value,-level, -algorithm, -tuned)
gat = gat[gat$measurement %in% c("recall","precision") ,]
r = gat[ gat$level == "READLEVEL" ,]
plot_recall(r,"","Effect of tuning - human t3 read level","default_vs_tuned/human_t3_READ_bar.pdf")


# BASE_LEVEL
cols <- c('character','character','character','character','character','character','numeric','character','character')
d = read.csv("/Users/hayerk/Google Drive/AlignerBenchmarkLocal/tuning/summary_human_t3r1_base_level_recall.txt", head =T,sep = "\t", colClasses = cols)
d$algorithm = sub(" tuned", "", d$algorithm)

# Plot the 100 plots
d$measurement[d$measurement == "aligned_correctly"] = "aligned correctly"
d$measurement[d$measurement == "aligned_ambiguously"] = "aligned ambiguously"
d$measurement[d$measurement == "aligned_incorrectly"] = "aligned incorrectly"
l  = spread(d[,c("level","algorithm","tuned",
                 "measurement","value")], measurement, value)
l$"aligned correctly" = 1-l$"aligned ambiguously"-l$unaligned-l$"aligned incorrectly"
gat = gather(l,measurement,value, -level, -algorithm,-tuned)
gat = gat[gat$measurement %in% c("aligned incorrectly","aligned ambiguously","unaligned","aligned correctly") ,]
gat$measurement = factor(gat$measurement, levels = c("aligned correctly","aligned ambiguously","aligned incorrectly","unaligned"))
r = gat[gat$level == "BASELEVEL",]
plot_100_plot(r,"percent of total bases","Effect of tuning - human t3 base level","default_vs_tuned/human_t3_BASE.pdf")
gat = gather(l,measurement,value,-level, -algorithm, -tuned)
gat = gat[gat$measurement %in% c("recall","precision") ,]
r = gat[ gat$level == "BASELEVEL" ,]
plot_recall(r,"","Effect of tuning - human t3 base level","default_vs_tuned/human_t3_BASE_bar.pdf")


# JUNC_LEVEL
cols <- c('character','character','character','character','character','character','numeric','character','character')
d = read.csv("/Users/hayerk/Google Drive/AlignerBenchmarkLocal/tuning/summary_human_t3r1_junction_level_recall.txt", head =T,sep = "\t", colClasses = cols)
d$algorithm = sub(" tuned", "", d$algorithm)
# Plot the 100 plots
d=d[d$level == "JUNCLEVEL",]
d = d[!duplicated(d), ]
d$measurement[d$measurement =="skipping_recall"] = "recall"
d$measurement[d$measurement =="skipping_precision"] = "precision"
l  = spread(d[,c("level","algorithm","tuned",
                 "measurement","value")], measurement, value)

l$recall[l$recall == 1] = NA
l$precision[l$precision == 1] = NA
gat = gather(l,measurement,value,-level, -algorithm, -tuned)
gat = gat[gat$measurement %in% c("recall","precision") ,]
r = gat[ gat$level == "JUNCLEVEL" ,]
plot_recall(r,"","Effect of tuning - human t3 junction level","default_vs_tuned/human_t3_JUNC.pdf")






