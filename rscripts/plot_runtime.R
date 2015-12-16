library(ggplot2)
library(tidyr)
setwd("~/github/aligner_benchmark/rscripts")

cols <- c('character','character','character','character','character','numeric','character')
d = read.csv("~/Google Drive/AlignerBenchmarkLocal/run_metrics.tsv", head =T,sep = "\t", colClasses = cols)
#d = read.csv("/Users/hayer/Downloads/test500.tsv", head =T,sep = "\t", colClasses = cols)

d$mean = rep(0,dim(d)[1])
d$sd = rep(0,dim(d)[1])

d = d[d$algorithm != "soap",]

for (i in 1:dim(d)[1]) {
  #print(i)
  if (d$measurement[i] %in% c("cpu_time")) {
    d$mean[i] = mean(d[d$species == d$species[i] & d$dataset == d$dataset[i] & d$algorithm == d$algorithm[i] & d$measurement == d$measurement[i] ,]$value/ 3600 / 16 * 60)
    d$sd[i] = sd(d[d$species == d$species[i] & d$dataset == d$dataset[i] & d$algorithm == d$algorithm[i] & d$measurement == d$measurement[i] ,]$value/ 3600 / 16 * 60) 
  } else if (d$measurement[i] %in% c("run_time","turnaround_time")) {
    d$mean[i] = mean(d[d$species == d$species[i] & d$dataset == d$dataset[i] & d$algorithm == d$algorithm[i] & d$measurement == d$measurement[i] ,]$value/ 3600 * 60)
    d$sd[i] = sd(d[d$species == d$species[i] & d$dataset == d$dataset[i] & d$algorithm == d$algorithm[i] & d$measurement == d$measurement[i] ,]$value/ 3600  * 60)
  } else {
    d$mean[i] = mean(d[d$species == d$species[i] & d$dataset == d$dataset[i] & d$algorithm == d$algorithm[i] & d$measurement == d$measurement[i] ,]$value)
    d$sd[i] = sd(d[d$species == d$species[i] & d$dataset == d$dataset[i] & d$algorithm == d$algorithm[i] & d$measurement == d$measurement[i] ,]$value) 
  }
  if (d$algorithm[i] == "novoalign" & d$measurement[i] %in% c("cpu_time","run_time","turnaround_time") ) {
    d$mean[i] = d$mean[i] / 16
    d$sd[i] = d$sd[i]  / 16
  }
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
  limits_new <- aes(ymax = mean + sd, ymin=mean - sd)
  ggplot(data, aes(fill=algorithm, y=mean, x=algorithm)) +
    geom_bar(stat="identity",position="dodge",width = .9) +
    geom_errorbar(limits_new, position="dodge", width=0.25) + 
    #geom_errorbar(sd, position="dodge", width=0.25)
    #geom_text(aes(label = tmp), size = 3) +
    ggtitle(title) +
    xlab("Algorithm") + ylab(measurement) + #ylim(c(-0.0001,1.0001)) +
    scale_x_discrete(limits=data[order(data$mean,decreasing = FALSE),]$algorithm)  + theme_gray(base_size=17) +#theme_light()+
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


#k = d[d$species == "human" & d$measurement == "cpu_time",]
#k = k[k$dataset == "t3" & k$replicate == "r1",]
#p <- ggplot(k, aes(fill=algorithm, y=mean, x=algorithm))
#limits_new <- aes(ymax = mean + sd, ymin=mean - sd)
#p + geom_bar(position="dodge", stat="identity") + geom_errorbar(limits_new, position="dodge", width=0.25) + #+ scale_y_log10() +
#scale_x_discrete(limits=k[order(k$mean,decreasing = FALSE),]$algorithm) + scale_fill_manual(values = k$color)

k = d[d$species == "human" & d$measurement == "run_time",]
k = k[k$dataset == "t3" & k$replicate == "r1",]
plot_my_data(k,"run time (in minutes)","human t3","run_time/human_t3_run_time.pdf")
k = d[d$species == "human" & d$measurement == "cpu_time",]
k = k[k$dataset == "t3" & k$replicate == "r1",]
plot_my_data(k,"cpu time  (in minutes)","human t3","run_time/human_t3_cpu_time.pdf")
k = d[d$species == "human" & d$measurement == "max_memory",]
k = k[k$dataset == "t3" & k$replicate == "r1",]
plot_my_data(k,"max memory (in MB)","human t3","run_time/human_t3_max_memory.pdf")


k = d[d$species == "malaria" & d$measurement == "run_time",]
k = k[k$dataset == "t3" & k$replicate == "r1",]
plot_my_data(k,"run time (in minutes)","malaria t3","run_time/malaria_t3_run_time.pdf")
k = d[d$species == "malaria" & d$measurement == "cpu_time",]
k = k[k$dataset == "t3" & k$replicate == "r1",]
plot_my_data(k,"cpu time  (in minutes)","malaria t3","run_time/malaria_t3_cpu_time.pdf")
k = d[d$species == "malaria" & d$measurement == "max_memory",]
k = k[k$dataset == "t3" & k$replicate == "r1",]
plot_my_data(k,"max memory (in MB)","malaria t3","run_time/malaria_t3_max_memory.pdf")



k = d[d$species == "human" & d$measurement == "run_time",]
k = k[k$dataset == "t2" & k$replicate == "r1",]
plot_my_data(k,"run time (in minutes)","human t2","run_time/human_t2_run_time.pdf")
k = d[d$species == "human" & d$measurement == "cpu_time",]
k = k[k$dataset == "t2" & k$replicate == "r1",]
plot_my_data(k,"cpu time  (in minutes)","human t2","run_time/human_t2_cpu_time.pdf")
k = d[d$species == "human" & d$measurement == "max_memory",]
k = k[k$dataset == "t2" & k$replicate == "r1",]
plot_my_data(k,"max memory (in MB)","human t2","run_time/human_t2_max_memory.pdf")


k = d[d$species == "malaria" & d$measurement == "run_time",]
k = k[k$dataset == "t2" & k$replicate == "r1",]
plot_my_data(k,"run time (in minutes)","malaria t2","run_time/malaria_t2_run_time.pdf")
k = d[d$species == "malaria" & d$measurement == "cpu_time",]
k = k[k$dataset == "t2" & k$replicate == "r1",]
plot_my_data(k,"cpu time (in minutes)","malaria t2","run_time/malaria_t2_cpu_time.pdf")
k = d[d$species == "malaria" & d$measurement == "max_memory",]
k = k[k$dataset == "t2" & k$replicate == "r1",]
plot_my_data(k,"max memory (in MB)","malaria t2","run_time/malaria_t2_max_memory.pdf")


k = d[d$species == "human" & d$measurement == "run_time",]
k = k[k$dataset == "t1" & k$replicate == "r1",]
plot_my_data(k,"run time (in minutes)","human t1","run_time/human_t1_run_time.pdf")
k = d[d$species == "human" & d$measurement == "cpu_time",]
k = k[k$dataset == "t1" & k$replicate == "r1",]
plot_my_data(k,"cpu time (in minutes)","human t1","run_time/human_t1_cpu_time.pdf")
k = d[d$species == "human" & d$measurement == "max_memory",]
k = k[k$dataset == "t1" & k$replicate == "r1",]
plot_my_data(k,"max memory (in MB)","human t1","run_time/human_t1_max_memory.pdf")


k = d[d$species == "malaria" & d$measurement == "run_time",]
k = k[k$dataset == "t1" & k$replicate == "r1",]
plot_my_data(k,"run time (in minutes)","malaria t1","run_time/malaria_t1_run_time.pdf")
k = d[d$species == "malaria" & d$measurement == "cpu_time",]
k = k[k$dataset == "t1" & k$replicate == "r1",]
plot_my_data(k,"cpu time (in minutes)","malaria t1","run_time/malaria_t1_cpu_time.pdf")
k = d[d$species == "malaria" & d$measurement == "max_memory",]
k = k[k$dataset == "t1" & k$replicate == "r1",]
plot_my_data(k,"max memory (in MB)","malaria t1","run_time/malaria_t1_max_memory.pdf")