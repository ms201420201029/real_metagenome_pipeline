q
# $1: profile file : reduced_LF_1000.profile
# $2: rho value cutoff : 0.6
# $3: grouping method : complete : "ward", "single", "complete", "average", "mcquitty", "median" or "centroid"
args <- commandArgs("T")
if(length(args)!=3){
  stop("argument number error: $0 <profile file> <rho value cutoff> <grouping method>")
}
methods=c("ward", "single", "complete", "average", "mcquitty", "median", "centroid")

if(!(args[3]%in%methods)){
  stop("grouping method corresponding to argument 3 does not exist, choose one of the following: \"ward\", \"single\", \"complete\", \"average\", \"mcquitty\", \"median\", \"centroid\"")
}

gene_marker_file_name=args[1]
rho=as.numeric(args[2])

profile=read.table(gene_marker_file_name,check.names=F,header=T,row.names=1,quote="",sep="\t")
#vare.dist <- as.dist(cor(t(profile),method="spearman"))
vare.dist <- as.dist(1-cor(t(profile),method="spearman"))
tt <- cutree(hclust(vare.dist,args[3]),h = 1-rho) 
mgs2gene = tapply(attributes(tt)$names,tt,c)
maxlength = max(sapply(mgs2gene,length))
f <- function(x){
  rowlength = length(x)
  length(x)=maxlength
  return(c(rowlength,x))
}
output=do.call(rbind,lapply(mgs2gene,f))
output=output[order(as.numeric(output[,1]),decreasing = T),]
write.table(output, paste("group_", gene_marker_file_name, sep=""), row.names=F, col.names=F,quote=F,sep="\t")
