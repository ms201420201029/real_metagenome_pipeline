source('{{ tool_default_dir }}/labels2colors.R')
profile.table = "{{ profile_table }}"
group.file = "{{ group_file }}"
pdf.file = "{{ pdf_file }}"

X=read.table(profile.table,header=TRUE,row.names=1,sep="\t",check.names=F,quote="")
group=read.table(group.file,header=F,row.names=1,check.names=F,quote="")
X = X[,rownames(group)]
color_list = group2corlor(group)
sample_colors = color_list[[1]]
group_colors  = color_list[[2]]
group_names = color_list[[3]]
group = color_list[[4]]

pdf(file="{{ pdf_file }}",11,8.5)
par(mar=c(4.1,5.1,4.1,2.1))


if(nrow(X)<=1){
  plot(0,type='n')
  text(1,0,'no item for plot')
}else{
  max_sample_name_length = max(mapply(nchar,as.character(group[,1])))
  g = unique(group)
  sample.list <- group[,1]
  library("ade4")
  library("car")
  Xdist=dist(t(X))
  X.dudi=dudi.pca(t(X),center=T,scale=T,scan=F)
  len=c()
  con=X.dudi$eig/sum(X.dudi$eig)*100
  con=round(con,2)
  
  sample_num = ncol(X)
  if(sample_num < 10){
    cex = 3
  }else if(sample_num < 20){
    cex = 2.2
  }else{
    cex = 1.2
  }
  
  nf<-layout(matrix(c(1,1,3,1,1,3,1,1,3,2,2,4,2,2,4),5,3,byrow=TRUE))
  
  
  #plot(X.dudi$li,col=sample_colors,pch=19,
  #     xlab=paste("PCA1(",con[1],"%)",sep=""),
  #     ylab=paste("PCA2(",con[2],"%)",sep=""),
  #     cex=cex,cex.axis=1.5,cex.lab=2)
	   
  plot(X.dudi$li,col=sample_colors,pch=19,
       xlab=paste("PCA1(",con[1],"%)",sep=""),
       ylab=paste("PCA2(",con[2],"%)",sep=""),
       cex=cex,cex.axis=1.5,cex.lab=2,
       xlim=c(min(X.dudi$li[1])-10,max(X.dudi$li[1])+10),
       ylim=c(min(X.dudi$li[2])-20,max(X.dudi$li[2])+20))
  
  dataEllipse(X.dudi$li[1]$Axis1,X.dudi$li[2]$Axis2,group[,1],
              col=rep("cadetblue1",time = length(group_names)),
              pch=19,group.labels=rep("",time = length(group_names)),
              level=.95, fill.alpha=0.1,center.cex=0,add = TRUE,plot.points=FALSE)
  # 左下
  par(mar=c(4.1,5.1,0,2.1))
  Y=rbind(X.dudi$li[1]$Axis1,as.character(group[,1]))
  Y=t(Y)
  Y=as.data.frame(Y)
  rownames(Y) = colnames(X)
  colnames(Y)=c("pc","time")
  Y$pc=as.numeric(as.character(Y$pc))
  levels=rev(g[,1])
  Y$time=factor(Y$time,levels)
  boxplot(pc ~ time, data = Y, col = rev(group_colors), horizontal=T,outline=T,cex.lab=1.6,cex.axis=1.2,xaxt="n")
  
  if (length(table(sample.list))==2){
    p_value_plot1=wilcox.test(X.dudi$li[,1][sample.list==names(table(sample.list))[1]],X.dudi$li[,1][sample.list==names(table(sample.list))[2]])$p.value
    legend("bottomright", paste0("p=", format(p_value_plot1,scientific=TRUE,digit=5)))
  }else{
    p_value_plot1=kruskal.test(X.dudi$li[,1],sample.list)$p.value
    legend("bottomright",paste0("p=",round(p_value_plot1,3)))
  }
  
  # 右上
  par(mar=c(4.1,0,3.1,5.1))
  Y1=rbind(X.dudi$li[2]$Axis2,as.character(group[,1]))
  Y1=t(Y1)
  Y1=as.data.frame(Y1)
  rownames(Y1) = colnames(X)
  colnames(Y1)=c("pc1","time1")
  Y1$pc1=as.numeric(as.character(Y1$pc1))
  levels=g[,1]
  Y1$time1=factor(Y1$time1,levels)
  boxplot(pc1 ~ time1, data = Y1, col = group_colors,horizontal=F,outline=T,cex.lab=1.6,cex.axis=1.2,yaxt="n")
  
  if (length(table(sample.list))==2){
    p_value_plot1=wilcox.test(X.dudi$li[,1][sample.list==names(table(sample.list))[1]],X.dudi$li[,1][sample.list==names(table(sample.list))[2]])$p.value
    legend("bottomright", paste0("p=", format(p_value_plot1,scientific=TRUE,digit=5)))
  }else{
    p_value_plot1=kruskal.test(X.dudi$li[,1],sample.list)$p.value
    legend("bottomright",paste0("p=",round(p_value_plot1,3)))
  }
  
  plot(0, xaxt='n', yaxt='n',type='n',xlab='',bty='n')
  legend("top",legend=group_names,col=group_colors,pch=15,cex=1.3,pt.cex=5,
         x.intersp=3,y.intersp=2,horiz=F,ncol = ceiling(length(group_colors)/6))
  
  write.csv(X.dudi$li,file=paste(substr(pdf.file,0,nchar(pdf.file)-4),"_point_inf.csv",sep = ""),fileEncoding="utf-8",quote = F)
  
}
dev.off()
