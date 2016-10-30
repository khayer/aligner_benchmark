library(ggplot2)
library(tidyr)
library(dplyr)
library(RColorBrewer)
library(ggrepel)
setwd("~/github/aligner_benchmark/rscripts")

cols <- c('character','character','character','character','character','character',
          'numeric','character')
#d = read.csv("/Users/kat//Google Drive/AlignerBenchmarkLocal/summary/summary_for_R_default.txt", head =T,sep = "\t", colClasses = cols)
#d = read.csv("/Users/hayer//Google Drive/AlignerBenchmarkLocal/summary/summary_for_R_default.txt", head =T,sep = "\t", colClasses = cols)
d = read.csv("~/Google Drive/AlignerBenchmarkLocal/default_summary.txt", head =T,sep = "\t", colClasses = cols)

d$algorithm = factor(d$algorithm)
nlevels(d$algorithm)
d$mean = rep(0,dim(d)[1])
d$sd = rep(0,dim(d)[1])


for (i in 1:dim(d)[1]) {
  #print(i)
  d$mean[i] = mean(d[d$species == d$species[i] & d$dataset == d$dataset[i] & d$algorithm == d$algorithm[i] & d$measurement == d$measurement[i] & d$level == d$level[i],]$value)
  d$sd[i] = sd(d[d$species == d$species[i] & d$dataset == d$dataset[i] & d$algorithm == d$algorithm[i] & d$measurement == d$measurement[i] & d$level == d$level[i],]$value) 
}

plot_my_data <- function(data, measurement, title, filename) {
  # data = k 
  # measurement one of #{recall, precision}
  print(measurement)
  data$tmp = data[,colnames(data) == measurement]
  print(head(data))
  print(data$tmp)
  ggplot(data,aes(x=algorithm, y=tmp, fill = algorithm)) + 
    geom_bar(stat="identity",position="dodge",width = .9, colour="black") +
    #geom_text(aes(label = tmp), size = 3) +
    ggtitle(title) +
    xlab("Algorithm") + ylab(measurement) + ylim(c(-0.0001,1.0001)) +
    scale_x_discrete(limits=data[order(data$tmp,decreasing = TRUE),]$algorithm)  + theme_gray(base_size=20) +#theme_light()+
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

plot_my_data_scatter_labels <- function(data, measurement1, measurement2, title, filename) {
  # data = k 
  # measurement one of #{recall, precision}
  print(measurement1)
  data$tmp1= data[,colnames(data) == measurement1]
  print(measurement2)
  data$color[data$color == "#F0E442"] = "cornflowerblue"
  data$tmp2 = data[,colnames(data) == measurement2]
  print(head(data))
  print(data$tmp2)
  data$algorithm = factor(data$algorithm)
  print(levels(data$algorithm))
  ggplot(data,aes(x=tmp1, y=tmp2, col = algorithm, shape= algorithm, label = algorithm)) + 
    geom_point(size=5) +
    #geom_text(aes(label = tmp), size = 3) +
    ggtitle(title) + theme_gray(base_size=20) + 
    scale_shape_manual(values=1:nlevels(data$algorithm) ) +
    xlab("Algorithm") + xlab(measurement1)+ ylab(measurement2)+ #ylim(c(-0.0001,1.0001)) +
    #scale_x_discrete(limits=data[order(data$tmp,decreasing = TRUE),]$algorithm)  + theme_gray(base_size=17) +#theme_light()+
    #theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = .5)) + #scale_fill_brewer(palette="Accent") +
    #scale_fill_manual(values = data$color) +
    scale_color_manual(values = data$color) + 
    #scale_colour_brewer(palette = "Dark2") +
    #geom_text(hjust = 0, nudge_x = 0.005, check_overlap = TRUE) +
    #xlim(c(.875,1.03)) +
    theme(panel.background = element_rect(colour = "gray97", fill="gray97")) + 
    
    
    guides(fill=FALSE) 
  ggsave(
    filename,
    width = 8.25,
    height = 5.75,
    dpi = 300
  )
  #data$tmp <- NULL
}

#plot_my_data_scatter_labels <- function(data, measurement1, measurement2, title, filename) {
  # data = k 
  # measurement one of #{recall, precision}
  print(measurement1)
  data$tmp1= data[,colnames(data) == measurement1]
  print(measurement2)
  data$color[data$color == "#F0E442"] = "cornflowerblue"
  data$tmp2 = data[,colnames(data) == measurement2]
  print(head(data))
  print(data$tmp2)
  data$algorithm = factor(data$algorithm)
  print(levels(data$algorithm))
  ggplot(data,aes(x=tmp1, y=tmp2, col = algorithm, shape= algorithm, label = algorithm)) + 
    geom_point(size=5) +
    #geom_text(aes(label = tmp), size = 3) +
    ggtitle(title) + theme_gray(base_size=20) + 
    scale_shape_manual(values=1:nlevels(data$algorithm) ) +
    xlab("Algorithm") + xlab(measurement1)+ ylab(measurement2)+ #ylim(c(-0.0001,1.0001)) +
    #scale_x_discrete(limits=data[order(data$tmp,decreasing = TRUE),]$algorithm)  + theme_gray(base_size=17) +#theme_light()+
    #theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = .5)) + #scale_fill_brewer(palette="Accent") +
    #scale_fill_manual(values = data$color) +
    scale_color_manual(values = data$color) + 
    #scale_colour_brewer(palette = "Dark2") +
    #geom_text(hjust = 0, nudge_x = 0.005, check_overlap = TRUE) +
    #xlim(c(.875,1.03)) +
    theme(panel.background = element_rect(colour = "gray97", fill="gray97")) + 
    #geom_text_repel(point.padding = unit(0.25, "lines")) +
    geom_text_repel(point.padding = unit(0.25, "lines")) +
    guides(fill=FALSE) 
  ggsave(
    filename,
    width = 8.25,
    height = 5.75,
    dpi = 300
  )
  #data$tmp <- NULL
}

plot_my_data_scatter <- function(data, measurement1, measurement2, title, filename, write_file = TRUE) {
  # data = k 
  # measurement one of #{recall, precision}
  print(measurement1)
  data$tmp1= data[,colnames(data) == measurement1]
  print(measurement2)
  data$color[data$color == "#F0E442"] = "cornflowerblue"
  data$tmp2 = data[,colnames(data) == measurement2]
  print(head(data))
  print(data$tmp2)
  data$algorithm = factor(data$algorithm)
  print(levels(data$algorithm))
  xlim <- range( data$tmp1 )
  ylim <- range( data$tmp2 )
  xlim[2] = 1.01
  ylim[2] = 1.01
  p = ggplot(data,aes(x=tmp1, y=tmp2, col = algorithm, label = algorithm)) + 
    geom_point(size=3,alpha = 0.85) +
    #geom_text(aes(label = tmp), size = 3) +
    ggtitle(title) + theme_bw(base_size=20) + 
    scale_shape_manual(values=1:nlevels(data$algorithm) ) +
    xlab("Algorithm") + xlab(measurement1)+ ylab(measurement2)+ #ylim(c(-0.0001,1.0001)) +
    #scale_x_discrete(limits=data[order(data$tmp,decreasing = TRUE),]$algorithm)  + theme_gray(base_size=17) +#theme_light()+
    #theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = .5)) + #scale_fill_brewer(palette="Accent") +
    #scale_fill_manual(values = data$color) +
    scale_color_manual(values = data$color) + 
    #scale_colour_brewer(palette = "Dark2") +
    #geom_text(hjust = 0, nudge_x = 0.005, check_overlap = TRUE) +
    #xlim(c(.875,1.03)) +
    theme(panel.background = element_rect(colour = "gray97", fill="gray97")) + 
    #geom_text_repel(point.padding = unit(0.25, "lines")) +
    geom_text_repel(force = 5, point.padding = unit(0.65, "lines"),arrow = arrow(length = unit(0.01, 'npc'))) +
    ylim(ylim) + xlim(xlim) + 
    guides(fill=FALSE) 
  print(p)
  if (write_file) {
    ggsave(
      filename,
      width = 8.25,
      height = 5.75,
      dpi = 300
    )
  }
  #data$tmp <- NULL
}

plot_my_data_bars <- function(data, measurement1, measurement2, title, filename) {
  # data = k 
  # measurement one of #{recall, precision}
  print(measurement1)
  data$tmp1= data[,colnames(data) == measurement1]
  print(measurement2)
  data$tmp2 = data[,colnames(data) == measurement2]
  print(head(data))
  print(data$tmp2)
  data$algorithm = factor(data$algorithm,level = unique(data[order(data$tmp2,decreasing = TRUE),]$algorithm))
  print(levels(data$algorithm))
  data$color = factor(data$color,level = unique(data[order(data$tmp2,decreasing = TRUE),]$color))
  print(levels(data$color))
  data = gather(data, thing, values, tmp1 , tmp2)
  data[data$thing == "tmp1",]$thing = "precision"
  data[data$thing == "tmp2",]$thing = "recall" 
  print(head(data))
  
  ggplot(data,aes(x=thing, y=values, fill = algorithm)) + 
    geom_bar(stat="identity",position="dodge",width = .9, colour="black") +
  #ggplot(data,aes(x=tmp1, y=tmp2, col = algorithm, shape= algorithm)) + 
    #geom_point(size=3) +
    #geom_text(aes(label = tmp), size = 3) +
    ggtitle(title) + theme_gray(base_size=20) +
    scale_shape_manual(values=1:nlevels(data$algorithm)) +
    theme(axis.text.x = element_text(size = 15,angle = 90, hjust = 1, vjust = .5,face ="bold",colour = "black")) +
    xlab("Algorithm") + #ylim(c(-0.0001,1.0001)) +
    #scale_x_discrete(limits=data[order(data$recall,decreasing = TRUE),]$algorithm)  +
    #scale_x_discrete(limits=data[order(data$tmp,decreasing = TRUE),]$algorithm)  + theme_gray(base_size=17) +#theme_light()+
    #theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = .5)) + #scale_fill_brewer(palette="Accent") +
    scale_fill_manual(values = levels(data$color)) +
    facet_grid(~algorithm) +
    theme(strip.text.x = element_text(size = 15, colour = "black", angle = 90, face = "bold")) + 
    
    guides(fill=FALSE) 
  ggsave(
    filename,
    width = 9.25,
    height = 6.75,
    dpi = 300
  )
  #data$tmp <- NULL
}

l  = spread(d[,c("species","dataset","replicate","level","algorithm",
                 "color","measurement","mean")], measurement, mean)
k = l[l$species == "human" & l$level == "READLEVEL",]
k = k[k$dataset == "t3",]
plot_my_data(k,"recall","human read level","read_level/human_t3_READ_recall.pdf")
plot_my_data(k,"precision","human read level","read_level/human_t3_READ_precision.pdf")
plot_my_data_scatter(k,"precision","recall","human read level","read_level/human_t3_READ_scatter.pdf")
plot_my_data_scatter_labels(k,"precision","recall","human read level","read_level/human_t3_READ_scatter_labels.pdf")
plot_my_data_bars(k,"precision","recall","human read level","read_level/human_t3_READ_bars.pdf")
k = l[l$species == "human" & l$level == "READLEVEL",]
k = k[k$dataset == "t2",]
plot_my_data(k,"recall","human read level","read_level/human_t2_READ_recall.pdf")
plot_my_data(k,"precision","human read level","read_level/human_t2_READ_precision.pdf")
plot_my_data_scatter(k,"precision","recall","human read level","read_level/human_t2_READ_scatter.pdf")
plot_my_data_scatter_labels(k,"precision","recall","human read level","read_level/human_t2_READ_scatter_labels.pdf")
plot_my_data_bars(k,"precision","recall","human read level","read_level/human_t2_READ_bars.pdf")
k = l[l$species == "human" & l$level == "READLEVEL",]
k = k[k$dataset == "t1",]
plot_my_data(k,"recall","human read level","read_level/human_t1_READ_recall.pdf")
plot_my_data(k,"precision","human read level","read_level/human_t1_READ_precision.pdf")
plot_my_data_scatter(k,"precision","recall","human read level","read_level/human_t1_READ_scatter.pdf")
plot_my_data_scatter_labels(k,"precision","recall","human read level","read_level/human_t1_READ_scatter_labels.pdf")
plot_my_data_bars(k,"precision","recall","human read level","read_level/human_t1_READ_bars.pdf")


k = l[l$species == "malaria" & l$level == "READLEVEL",]
k = k[k$dataset == "t3",]
plot_my_data(k,"recall","malaria read level","read_level/malaria_t3_READ_recall.pdf")
plot_my_data(k,"precision","malaria read level","read_level/malaria_t3_READ_precision.pdf")
plot_my_data_scatter(k,"precision","recall","malaria read level","read_level/malaria_t3_READ_scatter.pdf")
plot_my_data_scatter_labels(k,"precision","recall","malaria read level","read_level/malaria_t3_READ_scatter_labels.pdf")
plot_my_data_bars(k,"precision","recall","malaria read level","read_level/malaria_t3_READ_bars.pdf")
k = l[l$species == "malaria" & l$level == "READLEVEL",]
k = k[k$dataset == "t2",]
plot_my_data(k,"recall","malaria read level","read_level/malaria_t2_READ_recall.pdf")
plot_my_data(k,"precision","malaria read level","read_level/malaria_t2_READ_precision.pdf")
plot_my_data_scatter(k,"precision","recall","malaria read level","read_level/malaria_t2_READ_scatter.pdf")
plot_my_data_scatter_labels(k,"precision","recall","malaria read level","read_level/malaria_t2_READ_scatter_labels.pdf")
plot_my_data_bars(k,"precision","recall","malaria read level","read_level/malaria_t2_READ_bars.pdf")
k = l[l$species == "malaria" & l$level == "READLEVEL",]
k = k[k$dataset == "t1",]
plot_my_data(k,"recall","malaria read level","read_level/malaria_t1_READ_recall.pdf")
plot_my_data(k,"precision","malaria read level","read_level/malaria_t1_READ_precision.pdf")
plot_my_data_scatter(k,"precision","recall","malaria read level","read_level/malaria_t1_READ_scatter.pdf")
plot_my_data_scatter_labels(k,"precision","recall","malaria read level","read_level/malaria_t1_READ_scatter_labels.pdf")
plot_my_data_bars(k,"precision","recall","malaria read level","read_level/malaria_t1_READ_bars.pdf")

k = l[l$species == "human" & l$level == "BASELEVEL",]
k = k[k$dataset == "t3",]
plot_my_data(k,"recall","human base level","base_level/human_t3_BASE_recall.pdf")
plot_my_data(k,"precision","human base level","base_level/human_t3_BASE_precision.pdf")
plot_my_data_scatter(k,"precision","recall","human base level","base_level/human_t3_BASE_scatter.pdf")
plot_my_data_scatter_labels(k,"precision","recall","human base level","base_level/human_t3_BASE_scatter_labels.pdf")
plot_my_data_bars(k,"precision","recall","human base level","base_level/human_t3_BASE_bars.pdf")
k = l[l$species == "human" & l$level == "BASELEVEL",]
k = k[k$dataset == "t2",]
plot_my_data(k,"recall","human base level","base_level/human_t2_BASE_recall.pdf")
plot_my_data(k,"precision","human base level","base_level/human_t2_BASE_precision.pdf")
plot_my_data_scatter(k,"precision","recall","human base level","base_level/human_t2_BASE_scatter.pdf")
plot_my_data_scatter_labels(k,"precision","recall","human base level","base_level/human_t2_BASE_scatter_labels.pdf")
plot_my_data_bars(k,"precision","recall","human base level","base_level/human_t2_BASE_bars.pdf")
k = l[l$species == "human" & l$level == "BASELEVEL",]
k = k[k$dataset == "t1",]
plot_my_data(k,"recall","human base level","base_level/human_t1_BASE_recall.pdf")
plot_my_data(k,"precision","human base level","base_level/human_t1_BASE_precision.pdf")
plot_my_data_scatter(k,"precision","recall","human base level","base_level/human_t1_BASE_scatter.pdf")
plot_my_data_scatter_labels(k,"precision","recall","human base level","base_level/human_t1_BASE_scatter_labels.pdf")
plot_my_data_bars(k,"precision","recall","human base level","base_level/human_t1_BASE_bars.pdf")


k = l[l$species == "malaria" & l$level == "BASELEVEL",]
k = k[k$dataset == "t3",]
plot_my_data(k,"recall","malaria base level","base_level/malaria_t3_BASE_recall.pdf")
plot_my_data(k,"precision","malaria base level","base_level/malaria_t3_BASE_precision.pdf")
plot_my_data_scatter(k,"precision","recall","malaria base level","base_level/malaria_t3_BASE_scatter.pdf")
plot_my_data_scatter_labels(k,"precision","recall","malaria base level","base_level/malaria_t3_BASE_scatter_labels.pdf")
plot_my_data_bars(k,"precision","recall","malaria base level","base_level/malaria_t3_BASE_bars.pdf")
k = l[l$species == "malaria" & l$level == "BASELEVEL",]
k = k[k$dataset == "t2",]
plot_my_data(k,"recall","malaria base level","base_level/malaria_t2_BASE_recall.pdf")
plot_my_data(k,"precision","malaria base level","base_level/malaria_t2_BASE_precision.pdf")
plot_my_data_scatter(k,"precision","recall","malaria base level","base_level/malaria_t2_BASE_scatter.pdf")
plot_my_data_scatter_labels(k,"precision","recall","malaria base level","base_level/malaria_t2_BASE_scatter_labels.pdf")
plot_my_data_bars(k,"precision","recall","malaria base level","base_level/malaria_t2_BASE_bars.pdf")
k = l[l$species == "malaria" & l$level == "BASELEVEL",]
k = k[k$dataset == "t1",]
plot_my_data(k,"recall","malaria base level","base_level/malaria_t1_BASE_recall.pdf")
plot_my_data(k,"precision","malaria base level","base_level/malaria_t1_BASE_precision.pdf")
plot_my_data_scatter(k,"precision","recall","malaria base level","base_level/malaria_t1_BASE_scatter.pdf")
plot_my_data_scatter_labels(k,"precision","recall","malaria base level","base_level/malaria_t1_BASE_scatter_labels.pdf")
plot_my_data_bars(k,"precision","recall","malaria base level","base_level/malaria_t1_BASE_bars.pdf")

# BASE LEVEL AND DELETIONS
k = l[l$species == "human" & l$level == "BASELEVEL",]
k = k[k$dataset == "t3",]
plot_my_data(k,"deletions_recall","human deletions base level","deletions/human_t3_BASE_deletions_recall.pdf")
plot_my_data(k,"deletions_precision","human deletions base level","deletions/human_t3_BASE_deletions_precision.pdf")
plot_my_data_scatter(k,"deletions_precision","deletions_recall","human deletions base level","deletions/human_t3_BASE_deletions_scatter.pdf")
plot_my_data_bars(k,"deletions_precision","deletions_recall","human deletions base level","deletions/human_t3_BASE_deletions_bars.pdf")

k = l[l$species == "human" & l$level == "BASELEVEL",]
k = k[k$dataset == "t2",]
plot_my_data(k,"deletions_recall","human deletions base level","deletions/human_t2_BASE_deletions_recall.pdf")
plot_my_data(k,"deletions_precision","human deletions base level","deletions/human_t2_BASE_deletions_precision.pdf")
plot_my_data_scatter(k,"deletions_precision","deletions_recall","human deletions base level","deletions/human_t2_BASE_deletions_scatter.pdf")
plot_my_data_bars(k,"deletions_precision","deletions_recall","human deletions base level","deletions/human_t2_BASE_deletions_bars.pdf")

k = l[l$species == "human" & l$level == "BASELEVEL",]
k = k[k$dataset == "t1",]
plot_my_data(k,"deletions_recall","human deletions base level","deletions/human_t1_BASE_deletions_recall.pdf")
plot_my_data(k,"deletions_precision","human deletions base level","deletions/human_t1_BASE_deletions_precision.pdf")
plot_my_data_scatter(k,"deletions_precision","deletions_recall","human deletions base level","deletions/human_t1_BASE_deletions_scatter.pdf")
plot_my_data_bars(k,"deletions_precision","deletions_recall","human deletions base level","deletions/human_t1_BASE_deletions_bars.pdf")


k = l[l$species == "malaria" & l$level == "BASELEVEL",]
k = k[k$dataset == "t3",]
plot_my_data(k,"deletions_recall","malaria deletions base level","deletions/malaria_t3_BASE_deletions_recall.pdf")
plot_my_data(k,"deletions_precision","malaria deletions base level","deletions/malaria_t3_BASE_deletions_precision.pdf")
plot_my_data_scatter(k,"deletions_precision","deletions_recall","malaria deletions base level","deletions/malaria_t3_BASE_deletions_scatter.pdf")
plot_my_data_bars(k,"deletions_precision","deletions_recall","malaria deletions base level","deletions/malaria_t3_BASE_deletions_bars.pdf")
k = l[l$species == "malaria" & l$level == "BASELEVEL",]
k = k[k$dataset == "t2",]
plot_my_data(k,"deletions_recall","malaria deletions base level","deletions/malaria_t2_BASE_deletions_recall.pdf")
plot_my_data(k,"deletions_precision","malaria deletions base level","deletions/malaria_t2_BASE_deletions_precision.pdf")
plot_my_data_scatter(k,"deletions_precision","deletions_recall","malaria deletions base level","deletions/malaria_t2_BASE_deletions_scatter.pdf")
plot_my_data_bars(k,"deletions_precision","deletions_recall","malaria deletions base level","deletions/malaria_t2_BASE_deletions_bars.pdf")
k = l[l$species == "malaria" & l$level == "BASELEVEL",]
k = k[k$dataset == "t1",]
plot_my_data(k,"deletions_recall","malaria deletions base level","deletions/malaria_t1_BASE_deletions_recall.pdf")
plot_my_data(k,"deletions_precision","malaria deletions base level","deletions/malaria_t1_BASE_deletions_precision.pdf")
plot_my_data_scatter(k,"deletions_precision","deletions_recall","malaria deletions base level","deletions/malaria_t1_BASE_deletions_scatter.pdf")
plot_my_data_bars(k,"deletions_precision","deletions_recall","malaria deletions base level","deletions/malaria_t1_BASE_deletions_bars.pdf")

# BASE LEVEL AND INSERTIONS
k = l[l$species == "human" & l$level == "BASELEVEL",]
k = k[k$dataset == "t3",]
plot_my_data(k,"insertions_recall","human insertions base level","insertions/human_t3_BASE_insertions_recall.pdf")
plot_my_data(k,"insertions_precision","human insertions base level","insertions/human_t3_BASE_insertions_precision.pdf")
plot_my_data_scatter(k,"insertions_precision","insertions_recall","human insertions base level","insertions/human_t3_BASE_insertions_scatter.pdf")
plot_my_data_bars(k,"insertions_precision","insertions_recall","human insertions base level","insertions/human_t3_BASE_insertions_bars.pdf")

k = l[l$species == "human" & l$level == "BASELEVEL",]
k = k[k$dataset == "t2",]
plot_my_data(k,"insertions_recall","human insertions base level","insertions/human_t2_BASE_insertions_recall.pdf")
plot_my_data(k,"insertions_precision","human insertions base level","insertions/human_t2_BASE_insertions_precision.pdf")
plot_my_data_scatter(k,"insertions_precision","insertions_recall","human insertions base level","insertions/human_t2_BASE_insertions_scatter.pdf")
plot_my_data_bars(k,"insertions_precision","insertions_recall","human insertions base level","insertions/human_t2_BASE_insertions_bars.pdf")

k = l[l$species == "human" & l$level == "BASELEVEL",]
k = k[k$dataset == "t1",]
plot_my_data(k,"insertions_recall","human insertions base level","insertions/human_t1_BASE_insertions_recall.pdf")
plot_my_data(k,"insertions_precision","human insertions base level","insertions/human_t1_BASE_insertions_precision.pdf")
plot_my_data_scatter(k,"insertions_precision","insertions_recall","human insertions base level","insertions/human_t1_BASE_insertions_scatter.pdf")
plot_my_data_bars(k,"insertions_precision","insertions_recall","human insertions base level","insertions/human_t1_BASE_insertions_bars.pdf")

k = l[l$species == "malaria" & l$level == "BASELEVEL",]
k = k[k$dataset == "t3",]
plot_my_data(k,"insertions_recall","malaria insertions base level","insertions/malaria_t3_BASE_insertions_recall.pdf")
plot_my_data(k,"insertions_precision","malaria insertions base level","insertions/malaria_t3_BASE_insertions_precision.pdf")
plot_my_data_scatter(k,"insertions_precision","insertions_recall","malaria insertions base level","insertions/malaria_t3_BASE_insertions_scatter.pdf")
plot_my_data_bars(k,"insertions_precision","insertions_recall","malaria insertions base level","insertions/malaria_t3_BASE_insertions_bars.pdf")

k = l[l$species == "malaria" & l$level == "BASELEVEL",]
k = k[k$dataset == "t2",]
plot_my_data(k,"insertions_recall","malaria insertions base level","insertions/malaria_t2_BASE_insertions_recall.pdf")
plot_my_data(k,"insertions_precision","malaria insertions base level","insertions/malaria_t2_BASE_insertions_precision.pdf")
plot_my_data_scatter(k,"insertions_precision","insertions_recall","malaria insertions base level","insertions/malaria_t2_BASE_insertions_scatter.pdf")
plot_my_data_bars(k,"insertions_precision","insertions_recall","malaria insertions base level","insertions/malaria_t2_BASE_insertions_bars.pdf")
k = l[l$species == "malaria" & l$level == "BASELEVEL",]
k = k[k$dataset == "t1",]
plot_my_data(k,"insertions_recall","malaria insertions base level","insertions/malaria_t1_BASE_insertions_recall.pdf")
plot_my_data(k,"insertions_precision","malaria insertions base level","insertions/malaria_t1_BASE_insertions_precision.pdf")
plot_my_data_scatter(k,"insertions_precision","insertions_recall","malaria insertions base level","insertions/malaria_t1_BASE_insertions_scatter.pdf")
plot_my_data_bars(k,"insertions_precision","insertions_recall","malaria insertions base level","insertions/malaria_t1_BASE_insertions_bars.pdf")

# JUNCTIONS
k = l[l$species == "human" & l$level == "JUNCLEVEL",]
k = k[k$dataset == "t3",]
plot_my_data(k,"skipping_recall","human junction level","junctions/human_t3_JUNC_recall.pdf")
plot_my_data(k,"skipping_precision","human junction level","junctions/human_t3_JUNC_precision.pdf")
plot_my_data_scatter(k,"skipping_precision","skipping_recall","human junction level","junctions/human_t3_JUNC_scatter.pdf")
plot_my_data_bars(k,"skipping_precision","skipping_recall","human junction level","junctions/human_t3_JUNC_bars.pdf")

k = l[l$species == "human" & l$level == "JUNCLEVEL",]
k = k[k$dataset == "t2",]
plot_my_data(k,"skipping_recall","human junction level","junctions/human_t2_JUNC_recall.pdf")
plot_my_data(k,"skipping_precision","human junction level","junctions/human_t2_JUNC_precision.pdf")
plot_my_data_scatter(k,"skipping_precision","skipping_recall","human junction level","junctions/human_t2_JUNC_scatter.pdf")
plot_my_data_bars(k,"skipping_precision","skipping_recall","human junction level","junctions/human_t2_JUNC_bars.pdf")

k = l[l$species == "human" & l$level == "JUNCLEVEL",]
k = k[k$dataset == "t1",]
plot_my_data(k,"skipping_recall","human junction level","junctions/human_t1_JUNC_recall.pdf")
plot_my_data(k,"skipping_precision","human junction level","junctions/human_t1_JUNC_precision.pdf")
plot_my_data_scatter(k,"skipping_precision","skipping_recall","human junction level","junctions/human_t1_JUNC_scatter.pdf")
plot_my_data_bars(k,"skipping_precision","skipping_recall","human junction level","junctions/human_t1_JUNC_bars.pdf")


k = l[l$species == "malaria" & l$level == "JUNCLEVEL",]
k = k[k$dataset == "t3",]
plot_my_data(k,"skipping_recall","malaria junction level","junctions/malaria_t3_JUNC_recall.pdf")
plot_my_data(k,"skipping_precision","malaria junction level","junctions/malaria_t3_JUNC_precision.pdf")
plot_my_data_scatter(k,"skipping_precision","skipping_recall","malaria junction level","junctions/malaria_t3_JUNC_scatter.pdf")
plot_my_data_bars(k,"skipping_precision","skipping_recall","malaria junction level","junctions/malaria_t3_JUNC_bars.pdf")

k = l[l$species == "malaria" & l$level == "JUNCLEVEL",]
k = k[k$dataset == "t2",]
plot_my_data(k,"skipping_recall","malaria junction level","junctions/malaria_t2_JUNC_recall.pdf")
plot_my_data(k,"skipping_precision","malaria junction level","junctions/malaria_t2_JUNC_precision.pdf")
plot_my_data_scatter(k,"skipping_precision","skipping_recall","malaria junction level","junctions/malaria_t2_JUNC_scatter.pdf")
plot_my_data_bars(k,"skipping_precision","skipping_recall","malaria junction level","junctions/malaria_t2_JUNC_bars.pdf")
k = l[l$species == "malaria" & l$level == "JUNCLEVEL",]
k = k[k$dataset == "t1",]
plot_my_data(k,"skipping_recall","malaria junction level","junctions/malaria_t1_JUNC_recall.pdf")
plot_my_data(k,"skipping_precision","malaria junction level","junctions/malaria_t1_JUNC_precision.pdf")
plot_my_data_scatter(k,"skipping_precision","skipping_recall","malaria junction level","junctions/malaria_t1_JUNC_scatter.pdf")
plot_my_data_bars(k,"skipping_precision","skipping_recall","malaria junction level","junctions/malaria_t1_JUNC_bars.pdf")

# Plot the 100 plots
d$measurement[d$measurement == "aligned_correctly"] = "aligned correctly"
d$measurement[d$measurement == "aligned_ambiguously"] = "aligned ambiguously"
d$measurement[d$measurement == "aligned_incorrectly"] = "aligned incorrectly"
l  = spread(d[,c("species","dataset","replicate","level","algorithm",
                 "color","measurement","mean")], measurement, mean)

l$"aligned correctly" = 1-l$"aligned ambiguously"-l$unaligned-l$"aligned incorrectly"


gat = gather(l,measurement,mean, -species, -dataset, -replicate, -level, -algorithm, -color)
#cbPalette <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")
cbPalette <- c("#009E73", "#E69F00", "#CE3700", "#C0C0C0", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")
gat = gat[gat$measurement %in% c("aligned incorrectly","aligned ambiguously","unaligned","aligned correctly") ,]

gat$measurement = factor(gat$measurement, levels = c("aligned correctly","aligned ambiguously","aligned incorrectly","unaligned"))


plot_100_plot <- function(data,ylabs,titles,file) {
  ggplot(arrange(data, measurement), aes(x=algorithm, y=mean, fill=measurement, order = as.numeric(measurement))) + 
    geom_bar(stat="identity",width= .9) + 
    theme_gray(base_size=12) +#theme_light()+
    theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = .5)) +
    ylab(ylabs) +  ggtitle(titles) +
    scale_x_discrete(limits=data[order(data[data$measurement == "aligned correctly",]$mean,decreasing = TRUE),]$algorithm) +
    scale_fill_manual(values=cbPalette) 
  ggsave(
    file,
    width = 6.25,
    height = 5.25,
    dpi = 300
  )
}

r = gat[gat$dataset == "t3"  & gat$species == "human" & gat$level == "READLEVEL",]
plot_100_plot(r,"percent of total reads","human read level","read_level/human_t3_READ.pdf")
r = gat[gat$dataset == "t2"  & gat$species == "human" & gat$level == "READLEVEL",]
plot_100_plot(r,"percent of total reads","human read level","read_level/human_t2_READ.pdf")
r = gat[gat$dataset == "t1"  & gat$species == "human" & gat$level == "READLEVEL",]
plot_100_plot(r,"percent of total reads","human read level","read_level/human_t1_READ.pdf")

r = gat[gat$dataset == "t3"  & gat$species == "malaria" & gat$level == "READLEVEL",]
plot_100_plot(r,"percent of total reads","malaria read level","read_level/malaria_t3_READ.pdf")
r = gat[gat$dataset == "t2"  & gat$species == "malaria" & gat$level == "READLEVEL",]
plot_100_plot(r,"percent of total reads","malaria read level","read_level/malaria_t2_READ.pdf")
r = gat[gat$dataset == "t1"  & gat$species == "malaria" & gat$level == "READLEVEL",]
plot_100_plot(r,"percent of total reads","malaria read level","read_level/malaria_t1_READ.pdf")

r = gat[gat$dataset == "t3"  & gat$species == "human" & gat$level == "BASELEVEL",]
plot_100_plot(r,"percent of total bases","human base level","base_level/human_t3_BASE.pdf")
r = gat[gat$dataset == "t2"  & gat$species == "human" & gat$level == "BASELEVEL",]
plot_100_plot(r,"percent of total bases","human base level","base_level/human_t2_BASE.pdf")
r = gat[gat$dataset == "t1"  & gat$species == "human" & gat$level == "BASELEVEL",]
plot_100_plot(r,"percent of total bases","human base level","base_level/human_t1_BASE.pdf")

r = gat[gat$dataset == "t3"  & gat$species == "malaria" & gat$level == "BASELEVEL",]
plot_100_plot(r,"percent of total bases","malaria base level","base_level/malaria_t3_BASE.pdf")
r = gat[gat$dataset == "t2"  & gat$species == "malaria" & gat$level == "BASELEVEL",]
plot_100_plot(r,"percent of total bases","malaria base level","base_level/malaria_t2_BASE.pdf")
r = gat[gat$dataset == "t1"  & gat$species == "malaria" & gat$level == "BASELEVEL",]
plot_100_plot(r,"percent of total bases","malaria base level","base_level/malaria_t1_BASE.pdf")


plot_100_plot_multi <- function(data,ylabs,titles,file) {
  ggplot(arrange(data, measurement), aes(x=multi, y=mean, fill=measurement, order = as.numeric(measurement))) + 
    geom_bar(stat="identity",width= .9) + 
    theme_gray(base_size=15) +#theme_light()+
    #theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = .5)) +
    theme(axis.text.x = element_text(size=15, face ="bold",angle = 90, hjust = 1, vjust = .5),strip.text.x = element_text( angle = 90)) +
    ylab(ylabs) +  ggtitle(titles) + facet_grid(. ~ algorithm) +
    theme(strip.text.x = element_text(size = 15, colour = "black", angle = 90, face = "bold"))  +
    #scale_x_discrete(limits=data[order(data[data$measurement == "aligned correctly",]$mean,decreasing = TRUE),]$algorithm) +
    scale_fill_manual(values=cbPalette) +
    xlab("multi-mappers")
  ggsave(
    file,
    width = 9.75,
    height = 6.75,
    dpi = 300
  )
}

r = gat[gat$dataset == "t3"  & gat$species == "human" & gat$level %in% c("READLEVEL","READLEVEL(multimappers)"),]
r$multi = "included"
r[r$level == "READLEVEL",]$multi = "not included"
r$multi = factor(r$multi, levels = c("not included", "included"))
plot_100_plot_multi(r,"percent of total reads","human read level","multimapper/human_t3_READ_multi.pdf")
r = gat[gat$dataset == "t2"  & gat$species == "human" & gat$level %in% c("READLEVEL","READLEVEL(multimappers)"),]
r$multi = "included"
r[r$level == "READLEVEL",]$multi = "not included"
r$multi = factor(r$multi, levels = c("not included", "included"))
plot_100_plot_multi(r,"percent of total reads","human read level","multimapper/human_t2_READ_multi.pdf")
r = gat[gat$dataset == "t1"  & gat$species == "human" & gat$level %in% c("READLEVEL","READLEVEL(multimappers)"),]
r$multi = "included"
r[r$level == "READLEVEL",]$multi = "not included"
r$multi = factor(r$multi, levels = c("not included", "included"))
plot_100_plot_multi(r,"percent of total reads","human read level","multimapper/human_t1_READ_multi.pdf")

r = gat[gat$dataset == "t3"  & gat$species == "human" & gat$level %in% c("BASELEVEL","BASELEVEL(multimappers)"),]
r$multi = "included"
r[r$level == "BASELEVEL",]$multi = "not included"
r$multi = factor(r$multi, levels = c("not included", "included"))
plot_100_plot_multi(r,"percent of total reads","human base level","multimapper/human_t3_BASE_multi.pdf")

r = gat[gat$dataset == "t2"  & gat$species == "human" & gat$level %in% c("BASELEVEL","BASELEVEL(multimappers)"),]
r$multi = "included"
r[r$level == "BASELEVEL",]$multi = "not included"
r$multi = factor(r$multi, levels = c("not included", "included"))
plot_100_plot_multi(r,"percent of total reads","human base level","multimapper/human_t2_BASE_multi.pdf")

r = gat[gat$dataset == "t1"  & gat$species == "human" & gat$level %in% c("BASELEVEL","BASELEVEL(multimappers)"),]
r$multi = "included"
r[r$level == "BASELEVEL",]$multi = "not included"
r$multi = factor(r$multi, levels = c("not included", "included"))
plot_100_plot_multi(r,"percent of total reads","human base level","multimapper/human_t1_BASE_multi.pdf")
