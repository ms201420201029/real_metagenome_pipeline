args <- commandArgs(T)
if(length(args)!=3){stop("Rscript 707_compare_pathway.R ko.profile group.txt compare_pathway.txt")}
ko.profile <- args[1]
groupfile <- args[2]
outfile <- args[3]
source("/data_center_01/pipeline/real_metagenome/real_metagenome_v1.0.0/tool/labels2colors.R")
ko.data <- read.table(ko.profile,sep="\t",check.names = F,quote="",header = T,row.names = 1)
group <- read.table(groupfile,sep="\t",check.names = F,quote="",header = F,row.names = 1)
ko.profile <- ko.data[,rownames(group)]
colorslist <- group2corlor(group)
samplecolors <- colorslist[[1]]
groupcolors <- colorslist[[2]]
groupname <- colorslist[[3]]
group <- colorslist[[4]]

groupsub <- tapply(1:length(group[,1]), group[,1], c)
result.txt=c()
for(i in 1:length(groupsub)){
	if(length(which(apply(ko.data[,groupsub[groupname[i]][[1]]],1,sum)==0))==0)
	{
		temp <- ko.data
  		result.txt <- rbind(result.txt,data.frame(rownames(temp),  rep(groupcolors[i],nrow(temp)),  rep("W6",nrow(temp)),rep(1,nrow(temp))))
	}else{
		temp <- ko.data[-c(which(apply(ko.data[,groupsub[groupname[i]][[1]]],1,sum)==0)),]
		result.txt <- rbind(result.txt,data.frame(rownames(temp),  rep(groupcolors[i],nrow(temp)),  rep("W6",nrow(temp)),rep(1,nrow(temp))))
	}


}
write.table(result.txt,file = outfile,sep="\t",quote = F,col.names = F,row.names = F)
