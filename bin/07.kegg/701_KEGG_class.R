args <- commandArgs(T)
geneset.path <- args[1]
outfile <- args[2]
library(RColorBrewer)
source("/data_center_01/pipeline/real_metagenome/real_metagenome_v1.0.0/bin/07.kegg/mydotchart.R")
source("/data_center_01/pipeline/real_metagenome/real_metagenome_v1.0.0/tool/labels2colors.R")

data <- read.table(geneset.path,sep="\t",header = T,quote="",check.names = F)
gcolor <- pathcolors[unique(data[,1])]
#gcolor <- brewer.pal(length(unique(data[,1])),"Dark2")
x <- data[,3]
xmin <- min(x)
xmax <- max(x)
xdist <- xmax-xmin
if(xmin-xdist/10>0){
  xlim1 <- xmin-xdist/10
}else{
  xlim1=0
}
pdf(outfile,height = 9,width = 10)
mydotchart(x,labels = data[,2],groups = data[,1],gcolor = gcolor,lcolor = gcolor[data[,1]],color = gcolor[data[,1]],xlim = c(xlim1,xmax+xdist/10),xlab="Number of Gene",main="KEGG path Classification")
dev.off()

