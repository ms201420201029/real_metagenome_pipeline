# install.packages("clinfun") 
library("clinfun")
args <- commandArgs(T)
#profile.table = "species.profile"

profile.table = args[1]
group.file = args[2]
outdir = args[3]
#group.file = "time.txt"
p_cutoff = 0.1
#setwd("D:/Rworkspace/Rscript/huangy/luanz-Jonckheere-Terpstra/")


data = read.table(profile.table,header=T,row.names = 1,check.names = F,sep="\t",quote="",dec=".")
group = read.table(group.file,header=F,row.names = 1,check.names = F,sep="\t",quote="",dec=".")
group_num = length(tapply(1:nrow(group), group[,1], c))
data = data[,rownames(group)]
data = data/100
means_tmp = apply(data, 1, function(x) tapply(as.numeric(x), group[,1], mean))
means = t(apply(data, 1, function(x) tapply(as.numeric(x), group[,1], mean)))

pvalue = apply(data,1,function(x)  jonckheere.test(as.numeric(x),tapply(factor(group[,1],level=c("PreDeath0-3","PreDeath4-6","PreDeath7-12","PreDeath13-17")), 1:nrow(group), c))$p.value)
fdr <- p.adjust(pvalue, method = "fdr", n = length(pvalue))

enrichment = apply(means_tmp,2,function(x) rownames(means_tmp)[order(x,decreasing = T)[1]])
statsKWs<-data.frame(rownames(data),means,pvalue,fdr,enrichment,check.names=F)

if(!dir.exists(outdir)){
   dir.create(outdir,recursive=T)
}
# colnames(statsKWs)<- c("taxonname",meanname,"pvalue","fdr","enrichment")
write.table(statsKWs,file = paste0(outdir,"/diff.marker.tsv"),sep="\t",quote=F,row.names = F)

write.table(statsKWs[which(statsKWs[,group_num+2]<p_cutoff),],file=paste0(outdir,"/diff.marker.filter.tsv"),row.names=F,quote=F,sep="\t")

write.table(data[rownames(statsKWs[which(statsKWs[,group_num+2]<p_cutoff),]),],file=paste0(outdir,"/diff.marker.filter.profile.tsv"),quote=F,sep="\t")
