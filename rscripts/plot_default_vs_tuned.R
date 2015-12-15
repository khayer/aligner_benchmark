library(ggplot2)
library(tidyr)
setwd("~/github/aligner_benchmark/rscripts")

plot_100_plot <- function(data,ylabs,titles,file) {
  ggplot(data, aes(x=algorithm, y=value, fill=measurement, order = as.numeric(measurement))) + 
    geom_bar(stat="identity",width= .9) + 
    theme_gray(base_size=10) +#theme_light()+
    theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = .5)) +
    ylab(ylabs) +  ggtitle(titles) +
    #scale_x_discrete(limits=data[order(data[data$measurement == "aligned correctly",]$mean,decreasing = TRUE),]$algorithm) +
    scale_fill_manual(values=cbPalette) 
  ggsave(
    file,
    width = 6.25,
    height = 5.25,
    dpi = 300
  )
}

# READ_LEVEL
cols <- c('character','character','character','character','character','character','numeric','character','character')
#d = read.csv("/Users/kat//Google Drive/AlignerBenchmarkLocal/summary/summary_for_R_default.txt", head =T,sep = "\t", colClasses = cols)
d = read.csv("/Users/hayer//Google Drive/AlignerBenchmarkLocal/tweaked_vs_default/read_level_r_in.txt", head =T,sep = "\t", colClasses = cols)

# Plot the 100 plots
d$measurement[d$measurement == "aligned_correctly"] = "aligned correctly"
d$measurement[d$measurement == "aligned_ambiguously"] = "aligned ambiguously"
d$measurement[d$measurement == "aligned_incorrectly"] = "aligned incorrectly"
l  = spread(d[,c("level","algorithm",
                 "measurement","value")], measurement, value)

l$"aligned correctly" = 1-l$"aligned ambiguously"-l$unaligned-l$"aligned incorrectly"


gat = gather(l,measurement,value, -level, -algorithm)
#cbPalette <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")
cbPalette <- c("#009E73", "#E69F00", "#CE3700", "#999999", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")
gat = gat[gat$measurement %in% c("aligned incorrectly","aligned ambiguously","unaligned","aligned correctly") ,]

gat$measurement = factor(gat$measurement, levels = c("aligned correctly","aligned ambiguously","aligned incorrectly","unaligned"))




r = gat[gat$level == "READ",]
plot_100_plot(r,"percent of total reads","malaria t3 read level","default_vs_tuned/malaria_t3_READ.pdf")



# BASE_LEVEL
cols <- c('character','character','character','character','character','character','numeric','character','character')
#d = read.csv("/Users/kat//Google Drive/AlignerBenchmarkLocal/summary/summary_for_R_default.txt", head =T,sep = "\t", colClasses = cols)
d = read.csv("/Users/hayer//Google Drive/AlignerBenchmarkLocal/tweaked_vs_default/base_level_r_in.txt", head =T,sep = "\t", colClasses = cols)

# Plot the 100 plots
d$measurement[d$measurement == "aligned_correctly"] = "aligned correctly"
d$measurement[d$measurement == "aligned_ambiguously"] = "aligned ambiguously"
d$measurement[d$measurement == "aligned_incorrectly"] = "aligned incorrectly"
l  = spread(d[,c("level","algorithm",
                 "measurement","value")], measurement, value)

l$"aligned correctly" = 1-l$"aligned ambiguously"-l$unaligned-l$"aligned incorrectly"


gat = gather(l,measurement,value, -level, -algorithm)
#cbPalette <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")
cbPalette <- c("#009E73", "#E69F00", "#CE3700", "#999999", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")
gat = gat[gat$measurement %in% c("aligned incorrectly","aligned ambiguously","unaligned","aligned correctly") ,]

gat$measurement = factor(gat$measurement, levels = c("aligned correctly","aligned ambiguously","aligned incorrectly","unaligned"))


r = gat[gat$level == "BASE",]
plot_100_plot(r,"percent of total bases","malaria t3 base level","default_vs_tuned/malaria_t3_BASE.pdf")