profile.table = "{{ profile_table }}"
group.file = "{{ group_file }}"
txt.file = "{{ txt_file }}"

dataraw  <- read.table(profile.table,header = T,row.names = 1,sep = "\t",check.names = F,quote = "")
group  <- read.table(group.file,header = F,row.names = 1,sep = "\t",check.names = F,quote = "")
data = dataraw[,rownames(group)]
data[attributes(which(apply(data,1,sum)>0))$names,]
write.table(data*{{ num }},file=txt.file,sep="\t",quote=F)