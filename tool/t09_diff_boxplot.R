source("{{ tool_default_dir }}/labels2colors.R")
profile.table = "{{ profile_table }}"
p.file = "{{ p_file }}"
group.file = "{{ group_file }}"
pdf.file = "{{ pdf_file }}"
top = {{ top }}

library("ggplot2")
library("reshape2")
library("grid")
profile <- read.table(profile.table, header = T, check.names = F,row.names=1,sep="\t",quote="")
group <- read.table(group.file, header = F, check.names = F,row.names=1,sep="\t",quote="")
profile <- profile[,rownames(group)]
pvalue <- read.table(p.file, header = T, check.names = F,row.names=1,sep="\t",quote="")
if (nrow(profile)>top){
profile = profile[1:top,]
pvalue = pvalue[1:top,]
}
data <- melt(profile)
data[,3] <- rep(group[colnames(profile),1],each=nrow(profile))
data[,4] = rep(rownames(pvalue),ncol(profile))
data$value = log2(data$value)
min_num <- min(data$value[data$value!=-Inf])
data$value[data$value==-Inf] <- min_num
pdf(pdf.file,width=8, height=5)
p <- ggplot(data, aes(V4,value,fill=V3))+ geom_boxplot(outlier.size=1) +
theme( axis.text=element_text(colour="black"), axis.text.x=element_text(angle=60, size=8,hjust=1) ) +
scale_fill_discrete(name="Group", h=c(100,1000), c=100, l=60) +
labs(title="", x="", y="log2(Relative Abundance)") +
theme(legend.position='left')
p
dev.off()
