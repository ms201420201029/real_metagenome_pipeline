# $1: profile file : reduced_LF_1000.profile
# $2: health sample prefix : A for A[0-9]*
# $3: patient sample prefix : H for H[0-9]*
args <- commandArgs("T")
if(length(args)!=3){
  stop("argument number error: $0 <profile file> <health sample prefix> <patient sample prefix>")
}

cutoff_vector=c(1e-1,0.05,1e-2,1e-3,1e-4,1e-5,1e-6,1e-7,1e-8,1e-9,1e-10,1e-11)
profile_name=args[1]
profile_table=read.table(profile_name)

sample_names=colnames(profile_table)
HD_sample_number=unlist(grep(paste(args[2],"[0-9]*", sep=""), sample_names))
LD_sample_number=unlist(grep(paste(args[3],"[0-9]*", sep=""), sample_names))

p_values=apply(profile_table, 1, function(x,y=HD_sample_number, z=LD_sample_number) wilcox.test(unlist(x[y]),unlist(x[z]))$p.value )


adjusted_hochberg=p.adjust(p_values,method="hochberg")
adjusted_fdr=p.adjust(p_values,method="fdr")
adjusted_bonferroni=p.adjust(p_values,method="bonferroni")
p_value_table=cbind(p_values,adjusted_hochberg,adjusted_fdr,adjusted_bonferroni)
write.table(p_value_table,paste("p.values_list", profile_name,sep="_"), col.names=T,row.names=F, sep="\t")

#p.value_method_result=data.frame(threshold=0, p.value=0, hochberg=0, fdr=0, bonferroni=0)
p.value_method_result=matrix(0, nrow=length(cutoff_vector), ncol=5)
colnames(p.value_method_result)=c("threshold", "p.value", "hochberg", "fdr", "bonferroni")
#p.value_method_result[,1]=cutoff_vector
for (cutoff in cutoff_vector){
  p.value=length(which(p_values<cutoff))
  hochberg=length(which(adjusted_hochberg<cutoff))
  fdr=length(which(adjusted_fdr<cutoff))
  bonferroni=length(which(adjusted_bonferroni<cutoff))
  
  p.value_method_result[which(cutoff_vector == cutoff),]=c(cutoff, p.value, hochberg, fdr, bonferroni)
  
  #name1=strsplit(profile_name,"\\.")[[1]][1]
}
write.table(p.value_method_result, paste("p.value_table", profile_name,sep="_"), col.names=T,sep="\t", quote=F)
