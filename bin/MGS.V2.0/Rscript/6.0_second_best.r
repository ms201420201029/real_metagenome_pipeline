# $1: second grouping result : second_groups_A.profile
# $2: profile file : A.profile
# $3: most correlated number used : 15
args <- commandArgs("T")
if(length(args)!=3){
  stop("argument number error: $0 <second grouping result> <profile file> <most correlated number used>")
}

#Args <- commandArgs()
group_table=read.table(args[1],check.names =F)
gene_marker_profile=read.table(args[2],check.names =F)
most_correlated_number=as.numeric(args[3])
group_mean_file_name=paste("final_group_mean", args[2], sep="_")
most_connected_gene_file_name=paste("final_group_members_profile", args[2], sep="_")
group_number=nrow(group_table)


group_table=group_table[1:group_number,]
all_genes=group_table[,-1]
all_genes=all_genes[!is.na(all_genes)]
gene_marker_profile=gene_marker_profile[all_genes,]

rank_table=apply(gene_marker_profile, 1, rank)

rank_mean=apply(rank_table, 2, mean)

centered_table=rank_table-rank_mean

rho_table=t(centered_table)%*%centered_table

diagonal=sqrt(diag(rho_table))
rho_table=rho_table/diagonal
rho_table=t(rho_table)/diagonal
rho_table=as.data.frame(rho_table)


write.table(t(colnames(gene_marker_profile)), group_mean_file_name,col.names=F,row.names=F,quote=F,sep="\t")
write.table(t(colnames(gene_marker_profile)), most_connected_gene_file_name,col.names=F,row.names=F,quote=F,sep="\t")

get_type <- function(file_name){
  type_profile=unlist(strsplit(file_name,"_"))
  type_profile=type_profile[length(type_profile)]
  type=unlist(strsplit(type_profile,"[.]"))[1]
  type
}

type=get_type(args[1])
for(i in 1:nrow(group_table)){
  genes=as.character(unlist(group_table[i,2:(group_table[i,1]+1)]))
  sub_rho_table=rho_table[genes,genes]
  #print(genes)
  sub_rho_table["sum",]=apply(sub_rho_table,2,sum)
  sub_rho_table=sub_rho_table[,order(sub_rho_table["sum",],decreasing=T)]
  most_correlated_genes=colnames(sub_rho_table[,1:most_correlated_number])
  sub_gene_marker_profile=gene_marker_profile[most_correlated_genes,]
  write.table(sub_gene_marker_profile, most_connected_gene_file_name,append=T,col.names=F,quote=F,sep="\t")
  mean_profile=apply(sub_gene_marker_profile, 2, mean)
  all_genes=all_genes[!all_genes%in%genes]
  rho_table=rho_table[all_genes,all_genes]
  gene_marker_profile=gene_marker_profile[all_genes,]
  write.table(t(c(paste(type,i,sep="_"), mean_profile)), group_mean_file_name ,append=T,col.names=F,row.names=F,quote=F,sep="\t")
}


