library(ggplot2)
library(reshape2)
args <- commandArgs(T)
if(length(args)<2){stop("Rscript 708_metastats.R input.txt group.txt output.txt 8 cutoff_p")}
inputfile <- args[1]
groupfile <- args[2]
outputdir <- args[3]
gstart <- as.numeric(args[4])
cutoff_p <- args[5]
pflag <- args[6]

source("/data_center_01/pipeline/real_metagenome/real_metagenome_v1.0.0/bin/07.kegg/detect_DA_features.R")
source("/data_center_01/pipeline/real_metagenome/real_metagenome_v1.0.0/tool/labels2colors.R")
group <- read.table(groupfile,header = F,check.names = F,sep="\t",quote = "",row.names = 1)
color_list = group2corlor(group)
group_names = color_list[[3]]

jobj <- load_frequency_matrix(inputfile)
tt <- detect_differentially_abundant_features(jobj, gstart,paste0(outputdir,"metastats_result.txt"),pflag= pflag, threshold = cutoff_p,B=5)
write.table(cbind(tt[,c(1,2,5,8,9)],apply(tt,1,function(x) if(x[2]>x[5]){group_names[1]}else{group_names[2]})),file=paste0(outputdir,"diff.marker.filter.tsv"),sep="\t",quote=F,row.names=F,col.names=F)
data <- read.table(inputfile,sep="\t",check.names = F,quote="",header = T,row.names = 1)
temp_data <- as.data.frame(t(data[which(tt[,8]<cutoff_p),]))
write.table(data[which(tt[,8]<cutoff_p),],file=paste0(outputdir,"diff.marker.filter.profile.tsv"),sep="\t",quote=F)
##need group.txt
temp_data[,ncol(temp_data)+1]=c(rep(as.character(unique(group[,1])[1]),gstart-1),rep(as.character(unique(group[,1])[2]),ncol(data)-gstart+1))
data2 <- melt(temp_data)
colnames(data2) <- c("group","variable","value")
pdf(paste0(outputdir,"708_metastats_boxplot.pdf"))
# tt2 <- round(as.numeric(tt[,8]),3)
my_labeller <- label_bquote(
  rows = "",
  cols = NULL
)
ggplot(data=data2,aes(x=variable,y=value))+geom_boxplot(aes(fill=group))+
  facet_wrap( ~ variable, scales="free",labeller = my_labeller)+
  theme(strip.background = element_blank(),axis.title.x =element_text(size=14), axis.title.y=element_text(size=14))+
  scale_fill_manual(values=cols_brewer[1:2])+labs(x="Cazy number",y="abundance*100000")
dev.off()
