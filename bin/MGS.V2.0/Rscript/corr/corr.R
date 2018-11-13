#example Rscript /data_center_01/pipeline/real_metagenome/real_metagenome_v1.0.0/bin/MGS.V2.0/Rscript/corr/corr.R group/C1vsC2/04.mgs/pathway/final_group_mean_C1.profile group/C1vsC2/04.mgs/pathway/final_group_mean_C2.profile group/C1vsC2/04.mgs/fig/corr.pdf 
args <- commandArgs(T)
table1file = args[1]
table2file = args[2]
table1 = read.table(table1file,header=T,sep="\t",quote="",check.names=F,row.names=1)
table2 = read.table(table2file,header=T,sep="\t",quote="",check.names=F,row.names=1)
data = rbind(table1,table2)
library(corrplot)
pdf(args[3],12,12)
corrplot(cor(t(data)),mar=c(3,3,3,2),tl.cex=0.55,cl.cex=1.3)
dev.off()
