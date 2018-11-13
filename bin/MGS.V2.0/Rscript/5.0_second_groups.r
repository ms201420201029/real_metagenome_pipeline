# $1: first grouping result: group_A.profile
# $2: second grouping result: group_group_mean_A.profile
args <- commandArgs("T")
if(length(args)!=2){
  stop("argument number error: $0 <first grouping result> <second grouping result>")
}


first_groups=read.table(args[1])
second_groups_table=read.table(args[2])

sample_type=unlist(strsplit(args[1], "_"))
sample_type=sample_type[length(sample_type)]


final_groups_file_name=paste("second_groups", sample_type, sep="_")
first_groups=first_groups[,-1]

groups_table=as.matrix(second_groups_table[,-1])
#groups_booleen_table=!is.na(groups_table)
final_list=list()
for (row in 1:nrow(second_groups_table)){
  one_line=as.character(as.vector(groups_table[row,]))
  splitted=strsplit(one_line,"_")
  splitted=unlist(splitted)
  splitted=splitted[which(!is.na(splitted))]
  splitted=matrix(splitted,nrow=2)
  group_index=as.numeric(splitted[2,])
  group_index=group_index[which(!is.na(group_index))]
  genes=unlist(first_groups[group_index,])
  final_list[[row]]=as.character(genes[which(!is.na(genes))])
}


summary_number=as.numeric(summary(final_list)[,1])
names(summary_number)=1:length(summary_number)
summary_number=sort(summary_number, decreasing=T)
summary_name=names(summary_number)
list_index=as.numeric(names(summary_number))
longest=summary_number[1]
for (i in 1:length(summary_number)) {
  length=summary_number[i]
  line=paste(c(summary_number[summary_name[i]], final_list[[list_index[i]]], rep("NA",longest-length)), collapse="\t")
  if(i==1){
    write.table(line, final_groups_file_name, row.names=F, col.names=F,quote=F)
  }else{
    write.table(line, final_groups_file_name, row.names=F, col.names=F,quote=F,append=T)
  }
}

