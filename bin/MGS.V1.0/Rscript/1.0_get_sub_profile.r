# $1: profile file : reduced_LF_1000.profile
# $2: cutoff : 0.05
# $3: adjusting method : hochberg
# $4: health sample name prefix : H
# $5: patient sample name prefix : A
args <- commandArgs("T")
if(length(args)!=5){
  stop("argument number error: $0 <profile file> <cutoff> <adjusting method> <health sample name prefix> <patient sample name prefix>")
}
methods=c("holm", "hochberg", "hommel", "bonferroni", "BH", "BY", "fdr", "none")
if(!(args[3]%in%methods)){
  stop("adjusting method corresponding to argument 3 does not exist, choose one of the following: \"holm\", \"hochberg\", \"hommel\", \"bonferroni\", \"BH\", \"BY\", \"fdr\", \"none\"")
}
profile_name=args[1]
cutoff=as.numeric(args[2]) #c(0.05,1e-1,1e-2,1e-3,1e-4,1e-5,1e-6,1e-7,1e-8,1e-9,1e-10,1e-11)
adjust_method=args[3]  # "hochberg" "fdr" "bonferroni"

profile_table=read.table(profile_name)

sample_names=colnames(profile_table)
HD_sample_number=unlist(grep(paste(args[4],"[0-9]*", sep=""), sample_names))
LD_sample_number=unlist(grep(paste(args[5],"[0-9]*", sep=""), sample_names))

p_values=apply(profile_table, 1, function(x,y=HD_sample_number, z=LD_sample_number) wilcox.test(unlist(x[y]),unlist(x[z]))$p.value )


q_value=p.adjust(p_values,method=adjust_method)

reduced_profile=profile_table[which(q_value < cutoff),]

reduced_vector_1=apply(reduced_profile[,HD_sample_number], 1, mean)
reduced_vector_2=apply(reduced_profile[,LD_sample_number], 1, mean)

reduced_profile_1=reduced_profile[which(reduced_vector_1 > reduced_vector_2),]
reduced_profile_2=reduced_profile[which(reduced_vector_1 < reduced_vector_2),]



write.table(reduced_profile_1, paste(args[4], ".profile",sep=""), col.names=T,sep="\t", quote=F)
write.table(reduced_profile_2, paste(args[5], ".profile",sep=""), col.names=T,sep="\t", quote=F)
