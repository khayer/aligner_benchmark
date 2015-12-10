library(ggplot2)
library(tidyr)
setwd("~/github/aligner_benchmark/rscripts")

cols <- c('character','character','character','character','character','character',
          'numeric','character')
d = read.csv("/Users/hayer/Google Drive/AlignerBenchmarkLocal/summary/summary_for_R_default.txt", head =T,sep = "\t", colClasses = cols)

d$mean = rep(0,dim(d)[1])
d$sd = rep(0,dim(d)[1])


for (i in 1:dim(d)[1]) {
  #print(i)
  d$mean[i] = mean(d[d$dataset == d$dataset[i] & d$algorithm == d$algorithm[i] & d$measurement == d$measurement[i] & d$level == d$level[i],]$value)
  d$sd[i] = sd(d[d$dataset == d$dataset[i] & d$algorithm == d$algorithm[i] & d$measurement == d$measurement[i] & d$level == d$level[i],]$value) 
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










#ggplot(d[d$algorithm %in% c("contextmap2","crac","cracnoambiguity","gsnap",
#          "hisat", "mapsplice2", "novoalign", "olego","olegotwopass","rum",                                                    
#          "soapsplice", "star", "staronepass", "subread",
#          "tophat2coveragesearch-bowtie2sensitive",
#          "tophat2coveragesearch",
#          "tophat2nocoveragesearch-bowtie2sensitive",
#          "tophat2nocoveragesearch-bowtie2sensitive-testNoMateDist"),]
#k = l[l$algorithm %in% c("contextmap2","crac","gsnap",
#                         "hisat", "mapsplice2", "novoalign","olego","rum",                                                    
#                         "soapsplice", "star", "subread",
#                         "tophat2coveragesearch-bowtie2sensitive") &
#        l$replicate == "r1" & l$level == "READ",]

#k$algorithm[k$algorithm == "tophat2coveragesearch-bowtie2sensitive"] = "tophat2"
r = k[k$dataset=="t3",]
#k$color = c("blue","black","grey","pink","forestgreen","chartreuse","cornsilk","coral","cyan","gold1","lavender")
k = k[k$dataset == "t3",]
#png('../test.png',height=8400, width = 6000, res = 1200)

#dev.off()
ggsave(
  "ggtest.pdf",
  width = 6.25,
  height = 6.75,
  dpi = 300
)


ggplot(k,aes(x=algorithm, y=precision, fill = algorithm)) + 
  #coord_cartesian(ylim=c(-0.05,1.05),xlim = c(-0.05,1.05)) + 
  #geom_bar(stat="identity",position="dodge")  + 
  #geom_errorbar(aes(ymin = mean-sd, ymax = mean+sd), position="dodge") +
  geom_bar(stat="identity",position="dodge",width = .9, colour="black") + 
  #facet_grid(dataset ~ .)   +  
  ggtitle("human read level") +
  scale_x_discrete(limits=k[order(k$precision,decreasing = TRUE),]$algorithm)  + theme_gray(base_size=22) +#theme_light()+
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) + #scale_fill_brewer(palette="Accent") +
  scale_fill_manual(values = k$color) +
  guides(fill=FALSE) 
  

ggplot(k,aes(x=algorithm, y=precision)) + 
  #coord_cartesian(ylim=c(-0.05,1.05),xlim = c(-0.05,1.05)) + 
  #geom_bar(stat="identity",position="dodge")  + 
  #geom_errorbar(aes(ymin = mean-sd, ymax = mean+sd), position="dodge") +
  geom_bar(stat="identity",position="dodge",width = .75 , fill="white", colour="darkgreen") + 
  facet_grid(dataset ~ .) + scale_color_brewer(palette="Paired")  +  ggtitle("human read level") +
  scale_x_discrete(limits=r[order(r$precision,decreasing = TRUE),]$algorithm) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))






ggplot(l[l$algorithm %in% c("contextmap2","cracnoambiguity","gsnap",
                            "hisat", "mapsplice2", "novoalign","olegotwopass","rum",                                                    
                            "soapsplice", "star", "subread",
                            "tophat2coveragesearch-bowtie2sensitive") &
           l$replicate == "r1" & l$level == "BASE",]
       , aes(x =precision , y= recall, color=factor(algorithm)),stat="identity") + 
  coord_cartesian(ylim=c(-0.05,1.05),xlim = c(-0.05,1.05)) + 
  #geom_bar(stat="identity",position="dodge")  + 
  #geom_errorbar(aes(ymin = mean-sd, ymax = mean+sd), position="dodge") +
  geom_jitter( position = position_jitter(height = .008,width=.008),alpha=0.95,size=6) + 
  facet_grid(. ~ dataset) + scale_color_brewer(palette="Paired")  +  ggtitle("human base level")


ggplot(l[l$algorithm %in% c("contextmap2","cracnoambiguity","gsnap",
                            "hisat", "mapsplice2", "novoalign","olegotwopass","rum",                                                    
                            "soapsplice", "star", "subread",
                            "tophat2coveragesearch-bowtie2sensitive") &
           l$replicate == "r1" & l$level == "BASE",]
       , aes(x =insertions_precision , y= insertions_recall, color=factor(algorithm)),stat="identity") + 
  coord_cartesian(ylim=c(-0.05,1.05),xlim = c(-0.05,1.05)) + 
  #geom_bar(stat="identity",position="dodge")  + 
  #geom_errorbar(aes(ymin = mean-sd, ymax = mean+sd), position="dodge") +
  geom_jitter( position = position_jitter(height = .008,width=.008),alpha=0.95,size=6) + 
  facet_grid(. ~ dataset) + scale_color_brewer(palette="Paired")  +  ggtitle("insertions - human base level")

ggplot(l[l$algorithm %in% c("contextmap2","cracnoambiguity","gsnap",
                            "hisat", "mapsplice2", "novoalign","olegotwopass","rum",                                                    
                            "soapsplice", "star", "subread",
                            "tophat2coveragesearch-bowtie2sensitive") &
           l$replicate == "r1" & l$level == "BASE",]
       , aes(x =deletions_precision , y= deletions_recall, color=factor(algorithm)),stat="identity") + 
  coord_cartesian(ylim=c(-0.05,1.05),xlim = c(-0.05,1.05)) + 
  #geom_bar(stat="identity",position="dodge")  + 
  #geom_errorbar(aes(ymin = mean-sd, ymax = mean+sd), position="dodge") +
  geom_jitter( position = position_jitter(height = .008,width=.008),alpha=0.95,size=6) + 
  facet_grid(. ~ dataset) + scale_color_brewer(palette="Paired")  +  ggtitle("deletions - human base level")


ggplot(l[l$algorithm %in% c("contextmap2","cracnoambiguity","gsnap",
                            "hisat", "mapsplice2", "novoalign","olegotwopass","rum",                                                    
                            "soapsplice", "star", "subread",
                            "tophat2coveragesearch-bowtie2sensitive") &
           l$replicate == "r1" & l$level == "JUNC",]
       , aes(x =precision , y= recall, color=factor(algorithm)),stat="identity") + 
  coord_cartesian(ylim=c(-0.05,1.05),xlim = c(-0.05,1.05)) + 
  #geom_bar(stat="identity",position="dodge")  + 
  #geom_errorbar(aes(ymin = mean-sd, ymax = mean+sd), position="dodge") +
  geom_jitter( position = position_jitter(height = .008,width=.008),alpha=0.95,size=6) + 
  facet_grid(. ~ dataset) + scale_color_brewer(palette="Paired")  +  ggtitle("human junction level")

df <- data.frame(x = 1:10,
                 y = 1:10,
                 ymin = (1:10) - runif(10),
                 ymax = (1:10) + runif(10),
                 xmin = (1:10) - runif(10),
                 xmax = (1:10) + runif(10))

ggplot(data = df,aes(x = x,y = y)) + 
  geom_point() + 
  geom_errorbar(aes(ymin = ymin,ymax = ymax)) + 
  geom_errorbarh(aes(xmin = xmin,xmax = xmax))

cols <- c('character','character','character','character','character', 'numeric','numeric','integer','character',
          'numeric','numeric', 'character')
d = read.csv("results_IVT.txt",header = T,sep = "\t",na.strings = "NaN",colClasses = cols)
d$DataSet[d$DataSet == "Spikeins"] = "Simulated"

# With gene models fig6
ggplot(d[d$NumOfSpliceforms %in% c(0) &
           #d$Aligner == "none" &
           d$GeneModels == "true",]) +
  geom_rect(aes(xmax=0.67,xmin=0,ymax=1,ymin=0),fill = rgb(1,.91,.91)) +
  geom_rect(aes(xmax=1,xmin=0.67,ymax=0.25,ymin=0),fill = rgb(1,.91,.91)) +
  
  facet_grid(. ~ DataSet) +
  geom_vline(xintercept=seq(0.00, 1.00, by=0.25),color="gray86",size=.5) +
  geom_hline(yintercept=seq(0.00, 1.00, by=0.25),color="gray86",size=.5)+
  geom_vline(xintercept=seq(0.00, 1.00, by=1/8),color="gray86",size=.1) +
  geom_hline(yintercept=seq(0.00, 1.00, by=1/8),color="gray86",size=.1)+
  theme_bw(base_size = 18)+
  #theme_bw()  +
  facet_grid(. ~ DataSet) +
  #scale_fill_manual(values = alpha(rgb(1,.9,.9), c(.003,.003)))+
  
  geom_jitter(aes(x=Precision , y=Recall, color=factor(Algorithm),shape=factor(Aligner)), position = position_jitter(height = .008,width=.008),alpha=0.95,size=6) +
  
  scale_shape_manual(values=c(17,15,3),name="Aligner: ")+
  scale_color_manual(values=c("blue","red","black","darkgreen","orange","purple","turquoise1","yellow"), name="Algorithm: ") +
  #scale_size_manual(labels=c("1-10X","10-100X","100X and more"),values=c(3,5,7),breaks=c(0,1,2),name="X coverage") +
  theme(legend.position = "bottom") + ggtitle("With gene models")+ scale_y_continuous(limits=c(-0.01, 1.01)) + scale_x_continuous(limits=c(-0.1, 1.01)) +
  guides(shape = guide_legend(override.aes = list(size=6)),color= guide_legend(override.aes = list(size=6)))+ theme(text = element_text(size=15))

#PolyA
k = d[d$NumOfSpliceforms %in% c(0) &
        #d$Aligner == "none" &
        d$GeneModels == "true",]

gat = spread(k[k$DataSet == "PolyA" ,c("Algorithm","Aligner","Recall")],Aligner, Recall)
colnames(gat) = c("Recall","STAR","Tophat2")
write.table(gat, "IVT_PolyA_With_Anno.txt",sep="\t",row.names = FALSE, col.names = TRUE, append = FALSE)
gat = spread(k[k$DataSet == "PolyA" ,c("Algorithm","Aligner","Precision")],Aligner, Precision)
colnames(gat) = c("Precision","STAR","Tophat2")
write.table(gat, "IVT_PolyA_With_Anno.txt",sep="\t",row.names = FALSE, col.names = TRUE, append = TRUE)

#Ribo
gat = spread(k[k$DataSet == "Ribo" ,c("Algorithm","Aligner","Recall")],Aligner, Recall)
colnames(gat) = c("Recall","STAR","Tophat2")
write.table(gat, "IVT_Ribo_With_Anno.txt",sep="\t",row.names = FALSE, col.names = TRUE, append = FALSE)
gat = spread(k[k$DataSet == "Ribo" ,c("Algorithm","Aligner","Precision")],Aligner, Precision)
colnames(gat) = c("Precision","STAR","Tophat2")
write.table(gat, "IVT_Ribo_With_Anno.txt",sep="\t",row.names = FALSE, col.names = TRUE, append = TRUE)

#Simulated
gat = spread(k[k$DataSet == "Simulated" ,c("Algorithm","Aligner","Recall")],Aligner, Recall)
colnames(gat) = c("Recall","STAR","Tophat2","Simulated")
write.table(gat, "IVT_Simulated_With_Anno.txt",sep="\t",row.names = FALSE, col.names = TRUE, append = FALSE)
gat = spread(k[k$DataSet == "Simulated" ,c("Algorithm","Aligner","Precision")],Aligner, Precision)
colnames(gat) = c("Precision","STAR","Tophat2","Simulated")
write.table(gat, "IVT_Simulated_With_Anno.txt",sep="\t",row.names = FALSE, col.names = TRUE, append = TRUE)

# figS13
ggplot(d[d$NumOfSpliceforms %in% c(0) &
           #d$Aligner == "none" &
           d$GeneModels == "false",]) +
  geom_rect(aes(xmax=0.67,xmin=0,ymax=1,ymin=0),fill = rgb(1,.91,.91)) +
  geom_rect(aes(xmax=1,xmin=0.67,ymax=0.25,ymin=0),fill = rgb(1,.91,.91)) +
  
  facet_grid(. ~ DataSet) +
  geom_vline(xintercept=seq(0.00, 1.00, by=0.25),color="gray86",size=.5) +
  geom_hline(yintercept=seq(0.00, 1.00, by=0.25),color="gray86",size=.5)+
  geom_vline(xintercept=seq(0.00, 1.00, by=1/8),color="gray86",size=.1) +
  geom_hline(yintercept=seq(0.00, 1.00, by=1/8),color="gray86",size=.1)+
  theme_bw(base_size = 18)+
  #theme_bw()  +
  facet_grid(. ~ DataSet) +
  #scale_fill_manual(values = alpha(rgb(1,.9,.9), c(.003,.003)))+
  
  geom_jitter(aes(x=Precision , y=Recall, color=factor(Algorithm),shape=factor(Aligner)), position = position_jitter(height = .008,width=.008),alpha=0.95,size=6) +
  scale_shape_manual(values=c(16,17,15,3),name="Aligner: ")+
  #scale_shape_manual(labels=c("0-10X","10-100X","100X and more"),values=c(15,16,16,16,16,17,17,17,17,18,18,18,18),breaks=c(1,2,6,11),name="Splice Event")+
  scale_color_manual(values=c("grey","blue","red","black","orange","purple","darkgreen","turquoise1","yellow","tan4","chartreuse"), name="Algorithm: ") +
  #scale_size_manual(labels=c("1-10X","10-100X","100X and more"),values=c(3,5,7),breaks=c(0,1,2),name="X coverage") +
  theme(legend.position = "bottom") + ggtitle("Without gene models")+ scale_y_continuous(limits=c(-0.01, 1.01)) + scale_x_continuous(limits=c(-0.1, 1.01)) +
  guides(shape = guide_legend(override.aes = list(size=6)),color= guide_legend(override.aes = list(size=6)))+ theme(text = element_text(size=15))

k = d[d$NumOfSpliceforms %in% c(0) &
        #d$Aligner == "none" &
        d$GeneModels == "false",]

#PolyA
gat = spread(k[k$DataSet == "PolyA" ,c("Algorithm","Aligner","Recall")],Aligner, Recall)
colnames(gat) = c("Recall","none","STAR","Tophat2")
write.table(gat, "IVT_PolyA_Without_Anno.txt",sep="\t",row.names = FALSE, col.names = TRUE, append = FALSE)
gat = spread(k[k$DataSet == "PolyA" ,c("Algorithm","Aligner","Precision")],Aligner, Precision)
colnames(gat) = c("Precision","none","STAR","Tophat2")
write.table(gat, "IVT_PolyA_Without_Anno.txt",sep="\t",row.names = FALSE, col.names = TRUE, append = TRUE)

#Ribo
gat = spread(k[k$DataSet == "Ribo" ,c("Algorithm","Aligner","Recall")],Aligner, Recall)
colnames(gat) = c("Recall","none","STAR","Tophat2")
write.table(gat, "IVT_Ribo_Without_Anno.txt",sep="\t",row.names = FALSE, col.names = TRUE, append = FALSE)
gat = spread(k[k$DataSet == "Ribo" ,c("Algorithm","Aligner","Precision")],Aligner, Precision)
colnames(gat) = c("Precision","none","STAR","Tophat2")
write.table(gat, "IVT_Ribo_Without_Anno.txt",sep="\t",row.names = FALSE, col.names = TRUE, append = TRUE)

#Simulated
gat = spread(k[k$DataSet == "Simulated" ,c("Algorithm","Aligner","Recall")],Aligner, Recall)
colnames(gat) = c("Recall","none","STAR","Tophat2","Truth")
write.table(gat, "IVT_Simulated_Without_Anno.txt",sep="\t",row.names = FALSE, col.names = TRUE, append = FALSE)
gat = spread(k[k$DataSet == "Simulated" ,c("Algorithm","Aligner","Precision")],Aligner, Precision)
colnames(gat) = c("Precision","none","STAR","Tophat2","Truth")
write.table(gat, "IVT_Simulated_Without_Anno.txt",sep="\t",row.names = FALSE, col.names = TRUE, append = TRUE)