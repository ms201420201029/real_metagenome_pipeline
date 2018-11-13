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



profile=read.table(gene_marker_file_name)

rank_table=apply(profile, 1, rank)

rank_mean=apply(rank_table, 2, mean)

centered_table=rank_table-rank_mean

final_table=t(centered_table)%*%centered_table

diagonal=sqrt(diag(final_table))
final_table=final_table/diagonal
final_table=t(final_table)/diagonal





cc=final_table
d <-  1-cc
d <- as.dist(d)
hc <- hclust(d, args[3])
#plot(hc);abline(rho,0, col="red")
tt <- cutree(hc,h=1-rho)
#table(tt)
group_list=list()
for ( index in 1:length(table(tt)) ){
  group_list[[index]]=names(which(tt==index))
  #group_list[[i]]=c(group_list[[i]],names(i))
}



summary_number=as.numeric(summary(group_list)[,1])
names(summary_number)=1:length(summary_number)
summary_number=sort(summary_number, decreasing=T)
summary_name=names(summary_number)
list_index=as.numeric(names(summary_number))
longest=summary_number[1]
for (i in 1:length(summary_number)) {
  length=summary_number[i]
  line=paste(c(summary_number[summary_name[i]], group_list[[list_index[i]]], rep("NA",longest-length)), collapse="\t")
  if(i==1){
    write.table(line, paste("group_", gene_marker_file_name, sep=""), row.names=F, col.names=F,quote=F)
  }else{
    write.table(line, paste("group_", gene_marker_file_name, sep=""), row.names=F, col.names=F,quote=F,append=T)
  }
}



