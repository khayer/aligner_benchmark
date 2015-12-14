library(ggplot2)
library(tidyr)
setwd("~/github/aligner_benchmark/rscripts")

cols <- c('character','character','character','character','character','character',
          'numeric','character')
#d = read.csv("/Users/kat//Google Drive/AlignerBenchmarkLocal/summary/summary_for_R_default.txt", head =T,sep = "\t", colClasses = cols)
d = read.csv("/Users/hayer//Google Drive/AlignerBenchmarkLocal/summary/summary_for_R_default.txt", head =T,sep = "\t", colClasses = cols)



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
    scale_x_discrete(limits=data[order(data$tmp,decreasing = TRUE),]$algorithm)  + theme_gray(base_size=17) +#theme_light()+
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


l  = spread(d[,c("species","dataset","replicate","level","algorithm",
                 "color","measurement","mean")], measurement, mean)
k = l[l$species == "human" & l$level == "READ",]
k = k[k$dataset == "t3",]
plot_my_data(k,"recall","human read level","read_level/human_t3_READ_recall.pdf")
plot_my_data(k,"precision","human read level","read_level/human_t3_READ_precision.pdf")
k = l[l$species == "human" & l$level == "READ",]
k = k[k$dataset == "t2",]
plot_my_data(k,"recall","human read level","read_level/human_t2_READ_recall.pdf")
plot_my_data(k,"precision","human read level","read_level/human_t2_READ_precision.pdf")
k = l[l$species == "human" & l$level == "READ",]
k = k[k$dataset == "t1",]
plot_my_data(k,"recall","human read level","read_level/human_t1_READ_recall.pdf")
plot_my_data(k,"precision","human read level","read_level/human_t1_READ_precision.pdf")


k = l[l$species == "malaria" & l$level == "READ",]
k = k[k$dataset == "t3",]
plot_my_data(k,"recall","malaria read level","read_level/malaria_t3_READ_recall.pdf")
plot_my_data(k,"precision","malaria read level","read_level/malaria_t3_READ_precision.pdf")
k = l[l$species == "malaria" & l$level == "READ",]
k = k[k$dataset == "t2",]
plot_my_data(k,"recall","malaria read level","read_level/malaria_t2_READ_recall.pdf")
plot_my_data(k,"precision","malaria read level","read_level/malaria_t2_READ_precision.pdf")
k = l[l$species == "malaria" & l$level == "READ",]
k = k[k$dataset == "t1",]
plot_my_data(k,"recall","malaria read level","read_level/malaria_t1_READ_recall.pdf")
plot_my_data(k,"precision","malaria read level","read_level/malaria_t1_READ_precision.pdf")


k = l[l$species == "human" & l$level == "BASE",]
k = k[k$dataset == "t3",]
plot_my_data(k,"recall","human base level","base_level/human_t3_BASE_recall.pdf")
plot_my_data(k,"precision","human base level","base_level/human_t3_BASE_precision.pdf")
k = l[l$species == "human" & l$level == "BASE",]
k = k[k$dataset == "t2",]
plot_my_data(k,"recall","human base level","base_level/human_t2_BASE_recall.pdf")
plot_my_data(k,"precision","human base level","base_level/human_t2_BASE_precision.pdf")
k = l[l$species == "human" & l$level == "BASE",]
k = k[k$dataset == "t1",]
plot_my_data(k,"recall","human base level","base_level/human_t1_BASE_recall.pdf")
plot_my_data(k,"precision","human base level","base_level/human_t1_BASE_precision.pdf")


k = l[l$species == "malaria" & l$level == "BASE",]
k = k[k$dataset == "t3",]
plot_my_data(k,"recall","malaria base level","base_level/malaria_t3_BASE_recall.pdf")
plot_my_data(k,"precision","malaria base level","base_level/malaria_t3_BASE_precision.pdf")
k = l[l$species == "malaria" & l$level == "BASE",]
k = k[k$dataset == "t2",]
plot_my_data(k,"recall","malaria base level","base_level/malaria_t2_BASE_recall.pdf")
plot_my_data(k,"precision","malaria base level","base_level/malaria_t2_BASE_precision.pdf")
k = l[l$species == "malaria" & l$level == "BASE",]
k = k[k$dataset == "t1",]
plot_my_data(k,"recall","malaria base level","base_level/malaria_t1_BASE_recall.pdf")
plot_my_data(k,"precision","malaria base level","base_level/malaria_t1_BASE_precision.pdf")


# BASE LEVEL AND DELETIONS
k = l[l$species == "human" & l$level == "BASE",]
k = k[k$dataset == "t3",]
plot_my_data(k,"deletions_recall","human deletions base level","deletions/human_t3_BASE_deletions_recall.pdf")
plot_my_data(k,"deletions_precision","human deletions base level","deletions/human_t3_BASE_deletions_precision.pdf")
k = l[l$species == "human" & l$level == "BASE",]
k = k[k$dataset == "t2",]
plot_my_data(k,"deletions_recall","human deletions base level","deletions/human_t2_BASE_deletions_recall.pdf")
plot_my_data(k,"deletions_precision","human deletions base level","deletions/human_t2_BASE_deletions_precision.pdf")
k = l[l$species == "human" & l$level == "BASE",]
k = k[k$dataset == "t1",]
plot_my_data(k,"deletions_recall","human deletions base level","deletions/human_t1_BASE_deletions_recall.pdf")
plot_my_data(k,"deletions_precision","human deletions base level","deletions/human_t1_BASE_deletions_precision.pdf")

k = l[l$species == "malaria" & l$level == "BASE",]
k = k[k$dataset == "t3",]
plot_my_data(k,"deletions_recall","malaria deletions base level","deletions/malaria_t3_BASE_deletions_recall.pdf")
plot_my_data(k,"deletions_precision","malaria deletions base level","deletions/malaria_t3_BASE_deletions_precision.pdf")
k = l[l$species == "malaria" & l$level == "BASE",]
k = k[k$dataset == "t2",]
plot_my_data(k,"deletions_recall","malaria deletions base level","deletions/malaria_t2_BASE_deletions_recall.pdf")
plot_my_data(k,"deletions_precision","malaria deletions base level","deletions/malaria_t2_BASE_deletions_precision.pdf")
k = l[l$species == "malaria" & l$level == "BASE",]
k = k[k$dataset == "t1",]
plot_my_data(k,"deletions_recall","malaria deletions base level","deletions/malaria_t1_BASE_deletions_recall.pdf")
plot_my_data(k,"deletions_precision","malaria deletions base level","deletions/malaria_t1_BASE_deletions_precision.pdf")

# BASE LEVEL AND INSERTIONS
k = l[l$species == "human" & l$level == "BASE",]
k = k[k$dataset == "t3",]
plot_my_data(k,"insertions_recall","human insertions base level","insertions/human_t3_BASE_insertions_recall.pdf")
plot_my_data(k,"insertions_precision","human insertions base level","insertions/human_t3_BASE_insertions_precision.pdf")
k = l[l$species == "human" & l$level == "BASE",]
k = k[k$dataset == "t2",]
plot_my_data(k,"insertions_recall","human insertions base level","insertions/human_t2_BASE_insertions_recall.pdf")
plot_my_data(k,"insertions_precision","human insertions base level","insertions/human_t2_BASE_insertions_precision.pdf")
k = l[l$species == "human" & l$level == "BASE",]
k = k[k$dataset == "t1",]
plot_my_data(k,"insertions_recall","human insertions base level","insertions/human_t1_BASE_insertions_recall.pdf")
plot_my_data(k,"insertions_precision","human insertions base level","insertions/human_t1_BASE_insertions_precision.pdf")

k = l[l$species == "malaria" & l$level == "BASE",]
k = k[k$dataset == "t3",]
plot_my_data(k,"insertions_recall","malaria insertions base level","insertions/malaria_t3_BASE_insertions_recall.pdf")
plot_my_data(k,"insertions_precision","malaria insertions base level","insertions/malaria_t3_BASE_insertions_precision.pdf")
k = l[l$species == "malaria" & l$level == "BASE",]
k = k[k$dataset == "t2",]
plot_my_data(k,"insertions_recall","malaria insertions base level","insertions/malaria_t2_BASE_insertions_recall.pdf")
plot_my_data(k,"insertions_precision","malaria insertions base level","insertions/malaria_t2_BASE_insertions_precision.pdf")
k = l[l$species == "malaria" & l$level == "BASE",]
k = k[k$dataset == "t1",]
plot_my_data(k,"insertions_recall","malaria insertions base level","insertions/malaria_t1_BASE_insertions_recall.pdf")
plot_my_data(k,"insertions_precision","malaria insertions base level","insertions/malaria_t1_BASE_insertions_precision.pdf")


k = l[l$species == "human" & l$level == "JUNC",]
k = k[k$dataset == "t3",]
plot_my_data(k,"recall","human junction level","junctions/human_t3_JUNC_recall.pdf")
plot_my_data(k,"precision","human junction level","junctions/human_t3_JUNC_precision.pdf")
k = l[l$species == "human" & l$level == "JUNC",]
k = k[k$dataset == "t2",]
plot_my_data(k,"recall","human junction level","junctions/human_t2_JUNC_recall.pdf")
plot_my_data(k,"precision","human junction level","junctions/human_t2_JUNC_precision.pdf")
k = l[l$species == "human" & l$level == "JUNC",]
k = k[k$dataset == "t1",]
plot_my_data(k,"recall","human junction level","junctions/human_t1_JUNC_recall.pdf")
plot_my_data(k,"precision","human junction level","junctions/human_t1_JUNC_precision.pdf")


k = l[l$species == "malaria" & l$level == "JUNC",]
k = k[k$dataset == "t3",]
plot_my_data(k,"recall","malaria junction level","junctions/malaria_t3_JUNC_recall.pdf")
plot_my_data(k,"precision","malaria junction level","junctions/malaria_t3_JUNC_precision.pdf")
k = l[l$species == "malaria" & l$level == "JUNC",]
k = k[k$dataset == "t2",]
plot_my_data(k,"recall","malaria junction level","junctions/malaria_t2_JUNC_recall.pdf")
plot_my_data(k,"precision","malaria junction level","junctions/malaria_t2_JUNC_precision.pdf")
k = l[l$species == "malaria" & l$level == "JUNC",]
k = k[k$dataset == "t1",]
plot_my_data(k,"recall","malaria junction level","junctions/malaria_t1_JUNC_recall.pdf")
plot_my_data(k,"precision","malaria junction level","junctions/malaria_t1_JUNC_precision.pdf")


# Plot the 100 plots
d$measurement[d$measurement == "aligned_correctly"] = "aligned correctly"
d$measurement[d$measurement == "aligned_ambiguously"] = "aligned ambiguously"
d$measurement[d$measurement == "aligned_incorrectly"] = "aligned incorrectly"
l  = spread(d[,c("species","dataset","replicate","level","algorithm",
                 "color","measurement","mean")], measurement, mean)

l$"aligned correctly" = 1-l$"aligned ambiguously"-l$unaligned-l$"aligned incorrectly"


gat = gather(l,measurement,mean, -species, -dataset, -replicate, -level, -algorithm, -color)
#cbPalette <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")
cbPalette <- c("#009E73", "#E69F00", "#CE3700", "#999999", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")
gat = gat[gat$measurement %in% c("aligned incorrectly","aligned ambiguously","unaligned","aligned correctly") ,]

gat$measurement = factor(gat$measurement, levels = c("aligned correctly","aligned ambiguously","aligned incorrectly","unaligned"))


plot_100_plot <- function(data,ylabs,titles,file) {
  ggplot(data, aes(x=algorithm, y=mean, fill=measurement, order = as.numeric(measurement))) + 
    geom_bar(stat="identity",width= .9) + 
    theme_gray(base_size=10) +#theme_light()+
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

r = gat[gat$dataset == "t3"  & gat$species == "human" & gat$level == "READ",]
plot_100_plot(r,"percent of total reads","human read level","read_level/human_t3_READ.pdf")
r = gat[gat$dataset == "t2"  & gat$species == "human" & gat$level == "READ",]
plot_100_plot(r,"percent of total reads","human read level","read_level/human_t2_READ.pdf")
r = gat[gat$dataset == "t1"  & gat$species == "human" & gat$level == "READ",]
plot_100_plot(r,"percent of total reads","human read level","read_level/human_t1_READ.pdf")

r = gat[gat$dataset == "t3"  & gat$species == "malaria" & gat$level == "READ",]
plot_100_plot(r,"percent of total reads","malaria read level","read_level/malaria_t3_READ.pdf")
r = gat[gat$dataset == "t2"  & gat$species == "malaria" & gat$level == "READ",]
plot_100_plot(r,"percent of total reads","malaria read level","read_level/malaria_t2_READ.pdf")
r = gat[gat$dataset == "t1"  & gat$species == "malaria" & gat$level == "READ",]
plot_100_plot(r,"percent of total reads","malaria read level","read_level/malaria_t1_READ.pdf")

r = gat[gat$dataset == "t3"  & gat$species == "human" & gat$level == "BASE",]
plot_100_plot(r,"percent of total bases","human base level","base_level/human_t3_BASE.pdf")
r = gat[gat$dataset == "t2"  & gat$species == "human" & gat$level == "BASE",]
plot_100_plot(r,"percent of total bases","human base level","base_level/human_t2_BASE.pdf")
r = gat[gat$dataset == "t1"  & gat$species == "human" & gat$level == "BASE",]
plot_100_plot(r,"percent of total bases","human base level","base_level/human_t1_BASE.pdf")

r = gat[gat$dataset == "t3"  & gat$species == "malaria" & gat$level == "BASE",]
plot_100_plot(r,"percent of total bases","malaria base level","base_level/malaria_t3_BASE.pdf")
r = gat[gat$dataset == "t2"  & gat$species == "malaria" & gat$level == "BASE",]
plot_100_plot(r,"percent of total bases","malaria base level","base_level/malaria_t2_BASE.pdf")
r = gat[gat$dataset == "t1"  & gat$species == "malaria" & gat$level == "BASE",]
plot_100_plot(r,"percent of total bases","malaria base level","base_level/malaria_t1_BASE.pdf")
