library(ggplot2)
source('{{ tool_default_dir }}/labels2colors.R')
profile.table = "{{ profile_table }}"
group.file = "{{ group_file }}"
pdf.file = "{{ pdf_file }}"

X=read.table(profile.table,header=TRUE,row.names=1,sep="\t",check.names=F,quote="")
group=read.table(group.file,header=F,row.names=1,check.names=F,quote="")
X = X[,rownames(group)]
color_list = group2corlor(group)
sample_colors = color_list[[1]]
group_colors = color_list[[2]]
group_names = color_list[[3]]
group = color_list[[4]]
pdf(file="{{ pdf_file }}",6,5)
par(mar=c(4.1,5.1,4.1,2.1))

if(nrow(X)<=1){
	p<-plot(0,type='n')
	text(1,0,'no item for plot')
}else{
	max_sample_name_length = max(mapply(nchar,as.character(group[,1])))
	library("ade4")
	Xdist=dist(t(X))
	X.dudi=dudi.pca(t(X),center=T,scale=T,scan=F)
	len=c()
	con=X.dudi$eig/sum(X.dudi$eig)*100
	con=round(con,2)
	ymin=min(X.dudi$li[,2])
	ymax=max(X.dudi$li[,2])
	ylegend = (ymax - ymin) * 0.1
	xmin=min(X.dudi$li[,1])
	xmax=max(X.dudi$li[,1])
	xlegend = (xmax - xmin) * ( 0.12 * ceiling(max_sample_name_length / 4) )

    sample_num = ncol(X)
    if(sample_num < 10){
        cex = 3
    }else if(sample_num < 20){
        cex = 2.2
    }else{
        cex = 1.2
    }

    xlim = c(xmin,xmax+xlegend)
    ylim = c(ymin,ymax)
    X.dudi$li$group<-group[,1]
    X.dudi$li$time<-group[,2]
    scale_shape_manual <- c(19,1,2,5,18,15,17,8,9,10,11,12,13,14)[0:length(unique(group[,1]))]
    scale_color_manual <- group_colors
    p <-ggplot(X.dudi$li,aes(x=Axis1,y=Axis2,shape=group,colour=time))+geom_point(size=5)+scale_shape_manual(values = scale_shape_manual)+scale_color_manual(values = scale_color_manual)
    p <- p+labs(x =paste("PCA1(",con[1],"%)"),y =paste("PCA2(",con[2],"%)"))
    p <-p + theme_bw()
    p <- p + theme(panel.grid.major=element_line(colour=NA))
    p <- p+theme(axis.title.x = element_text(size=17,colour = "black",face = "bold"),axis.title.y = element_text(size=17,colour = "black",face = "bold"),axis.text.y = element_text(size=17,colour = "black"),axis.text.x = element_text(size=17,colour = "black"))


	write.csv(X.dudi$li,file=paste(substr(pdf.file,0,nchar(pdf.file)-4),"_point_inf.csv",sep = ""),fileEncoding="utf-8",quote = F)
}
p
dev.off()
