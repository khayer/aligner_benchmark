library(ggplot2)
library(tidyr)
setwd("~/github/aligner_benchmark/rscripts")

cols <- c('character','character','character','character','character','numeric','character')
#d = read.csv("/Users/kat//Google Drive/AlignerBenchmarkLocal/summary/summary_for_R_default.txt", head =T,sep = "\t", colClasses = cols)
d = read.csv("/Users/hayer//Google Drive/AlignerBenchmarkLocal/summary_default_running_stats.txt", head =T,sep = "\t", colClasses = cols)

d$mean = rep(0,dim(d)[1])
d$sd = rep(0,dim(d)[1])

d = d[d$algorithm != "soap",]

for (i in 1:dim(d)[1]) {
  #print(i)
  d$mean[i] = mean(log(d[d$species == d$species[i] & d$dataset == d$dataset[i] & d$algorithm == d$algorithm[i] & d$measurement == d$measurement[i] ,]$value))
  d$sd[i] = sd(log(d[d$species == d$species[i] & d$dataset == d$dataset[i] & d$algorithm == d$algorithm[i] & d$measurement == d$measurement[i] ,]$value) )
}

test = c(28372.81,19481.55,22020.3)
mean(test)
#[1] 23291.55
sd(test)
#[1] 4579.922

plot_my_data <- function(data, measurement, title, filename) {
  # data = k 
  # measurement one of #{recall, precision}
  print(measurement)
  #data$tmp = data[,colnames(data) == measurement]
  print(head(data))
  #print(data$tmp)
  ggplot(data,aes(x=algorithm, y=mean, fill = algorithm)) + 
    geom_bar(stat="identity",position="dodge",width = .9, colour="black") +
    #geom_errorbar(sd, position="dodge", width=0.25)
    #geom_text(aes(label = tmp), size = 3) +
    ggtitle(title) +
    xlab("Algorithm") + ylab(measurement) + ylim(c(-0.0001,1.0001)) +
    scale_x_discrete(limits=data[order(data$measurement,decreasing = TRUE),]$algorithm)  + theme_gray(base_size=17) +#theme_light()+
    theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = .5)) + #scale_fill_brewer(palette="Accent") +
    scale_fill_manual(values = data$color) +
    
    guides(fill=FALSE) 
  ggsave(
    filename,
    width = 6.25,
    height = 6.75,
    dpi = 300
  )
  #data$tmp <- NULL
}


k = d[d$species == "human" & d$measurement == "cpu_time",]
k = k[k$dataset == "t3" & k$replicate == "r1",]
p <- ggplot(k, aes(fill=algorithm, y=mean, x=algorithm))
limits_new <- aes(ymax = mean + sd, ymin=mean - sd)
p + geom_bar(position="dodge", stat="identity") + geom_errorbar(limits_new, position="dodge", width=0.25) + #+ scale_y_log10() +
scale_x_discrete(limits=k[order(k$mean,decreasing = FALSE),]$algorithm) + scale_fill_manual(values = k$color)
plot_my_data(k,"cpu_time","human t3","run_time/human_t3_cpu_time.pdf")
plot_my_data(k,"precision","human read level","read_level/human_t3_READ_precision.pdf")