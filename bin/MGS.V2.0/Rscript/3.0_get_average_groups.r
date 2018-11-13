# $1: group file : group_A.profile
# $2: profile file : A.profile
# $3: group number : 62
# $4: most correlated number in a number: 20
args <- commandArgs("T")
if(length(args)!=4){
  stop("argument number error: $0 <profile file> <profile file> <group number> <most correlated number in a group>")
}

group_table=read.table(args[1],check.names =F,header=F,quote="",sep="\t")
gene_marker_profile=read.table(args[2],check.names =F,header=T,row.names=1,quote="",sep="\t")
group_number=as.numeric(args[3])
most_correlated_number=as.numeric(args[4])

group_mean_file_name=paste("group_mean", args[2], sep="_")

group_table=group_table[1:group_number,]
all_genes=group_table[,-1]
all_genes=all_genes[!is.na(all_genes)]
gene_marker_profile=gene_marker_profile[all_genes,]

rho_table <- as.data.frame(cor(t(gene_marker_profile),method="spearman"))

write.table(t(colnames(gene_marker_profile)), group_mean_file_name,col.names=F,row.names=F,quote=F,sep="\t")
o = which(apply(group_table,1,function(x) length(which(!is.na(x) == TRUE)))>most_correlated_number)
for(i in 1:max(o)){
  genes=as.character(unlist(group_table[i,2:(group_table[i,1]+1)]))
  sub_rho_table=rho_table[genes,genes]
  #print(genes)
  sub_rho_table["sum",]=apply(sub_rho_table,2,sum)
  sub_rho_table=sub_rho_table[,order(sub_rho_table["sum",],decreasing=T)]
  most_correlated_genes=colnames(sub_rho_table[,1:most_correlated_number])
  sub_gene_marker_profile=gene_marker_profile[most_correlated_genes,]
  mean_profile=apply(sub_gene_marker_profile, 2, mean)
#  all_genes=all_genes[!all_genes%in%genes]
#  rho_table=rho_table[all_genes,all_genes]
#  gene_marker_profile=gene_marker_profile[all_genes,]
  write.table(t(c(paste("group_",i,sep=""), mean_profile)), group_mean_file_name ,append=T,col.names=F,row.names=F,quote=F,sep="\t")
}

