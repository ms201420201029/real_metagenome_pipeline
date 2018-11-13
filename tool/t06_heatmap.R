source("{{ tool_default_dir }}/labels2colors.R")
profile.table <- "{{ profile_table }}"
out.dir <- "{{ out_dir }}"
group.file <- "{{ group_file }}"
top={{ top }}
pdf.file = "{{ pdf_file }}"

data <- read.table(profile.table,check.names = F,sep="\t",quote="",header = T,row.names = 1)
if(nrow(data)>=top){
  data <- data[order(apply(data,1,sum),decreasing = T)[1:top],]
}
write.table(data,file=paste0(out.dir,"for_plot_filter.txt"),sep="\t",quote=F)  

group=read.table(group.file,sep="\t",header=F,row.names=1,check.names=F,quote="")
data = data[,rownames(group)]
color_list = group2corlor(group)
sample_colors=color_list[[1]]
group_colors= color_list[[2]]
group_names = color_list[[3]]
group = color_list[[4]]

library(gplots)
pdf(pdf.file,12,16)
if(ncol(data)<=2){
  plot(0,type="n")
  text(1,0,"no item for plot or sample less than 2")
}
max.genus.name.length = max(mapply(nchar,rownames(data)))
if(max.genus.name.length < 10){
  oma.right = max.genus.name.length
  cexRow = 3
}else if(max.genus.name.length > 11 && max.genus.name.length < 20){
  cexRow = 2
  oma.right = 0.8*max.genus.name.length-3.9
}else {
  cexRow =1.8
  oma.right = 0.9*max.genus.name.length-3.9
}
par(oma=c(0,0,0,oma.right))
col = colorRampPalette(c("lightblue", "yellow", "orange", "red"),bias=3)(3000)
if((ncol(data)>100) && (ncol(data)<200)){
  cexCol=0.5
}else if(ncol(data)>=200){
  cexCol = 0.3
}else{
  cexCol=-0.0133*ncol(data)+2
}



Colv=TRUE
Rowv=TRUE
lmat = rbind(c(5,5),c(0,4),c(0,1),c(3,2),c(0,6))
lhei = c(0.5,0.8,0.2,4,0.5)
lwid = c(1,3)
legend_pos = 'topleft'

heatmap.2(as.matrix(data),
          col=col,labRow=rownames(data),ColSideColors=sample_colors,
          cexRow=cexRow,cexCol=cexCol,
          Colv=Colv,Rowv=Rowv,
          offsetRow=0.1,symkey=FALSE,density.info="none",
          trace="none",
          margins=c(5,5),
          lmat = lmat,lhei=lhei,lwid=lwid,
          colsep=c(1:ncol(data)),rowsep=c(1:nrow(data)),sepcolor="black",sepwidth=c(0.01, 0.01),
          key.title=NA, # no title
          key.xlab="relative abundance" # no xlab
)
if(length(group_names)>10){
  legend.cex=0.7
}else{
  legend.cex=1
}
legend(legend_pos,pch=15,col=group_colors, legend=group_names,xpd=T)
#plot(0, type = "n", xaxt = "n", yaxt = "n", bty ="n", xlab = "", ylab = "")
#legend("left",pch =15,col=col,legend=rownames(data))
dev.off()
