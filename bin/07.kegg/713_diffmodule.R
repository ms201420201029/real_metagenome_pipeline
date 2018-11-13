profile.table <- "{{ profile_table }}"
group.file <- "{{ group_file }}"
out.dir = "{{ out_dir }}"
data = read.table(profile.table,header=TRUE,check.names=F,row.names=1,quote="",sep="\t");
group = read.table(group.file,header=F,check.names=F,row.names=1,quote="",sep="\t")
group1 = as.vector(tapply(rownames(group),group[,1],c)[[1]])
group2 = as.vector(tapply(rownames(group),group[,1],c)[[2]])
data = data[,rownames(group)]
group1_number = which(colnames(data) %in% group1);
group2_number = which(colnames(data) %in% group2);
mu = length(group1)*(length(group1)+length(group2)+1)/2;
sigma = length(group2)*length(group1)*(length(group1)+length(group2)+1)/12;
statistic_1 = apply(data,1,function(x,y=group1_number,z=group2_number) as.vector(wilcox.test(unlist(x[y]),unlist(x[z]),pair=FALSE,alternative="greater")$p.value));
statistic_2 = apply(data,1,function(x,y=group1_number,z=group2_number) as.vector(wilcox.test(unlist(x[z]),unlist(x[y]),pair=FALSE,alternative="greater")$p.value));
z_score_1 = (statistic_1-mu)/sqrt(sigma);
z_score_2 = (statistic_2-mu)/sqrt(sigma);
group1_name = names(tapply(rownames(group),group[,1],c))[1]
group2_name = names(tapply(rownames(group),group[,1],c))[2]
cat(paste(group1_name,group2_name,sep="@@@"))
write.table(statistic_1,paste0(out.dir,group1_name,"_group1.ko.zscore"),col.names=FALSE,sep="\t",quote=FALSE);
write.table(statistic_2,paste0(out.dir,group2_name,"_group2.ko.zscore"),col.names=FALSE,sep="\t",quote=FALSE);
