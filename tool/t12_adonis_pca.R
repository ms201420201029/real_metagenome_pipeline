###adonis_bray###
library("vegan")
library("ade4")

source("{{ tool_default_dir }}/labels2colors.R")
profile.table <- "{{ profile_table }}"
group.file <- "{{ group_file }}"
pdf.file = "{{ pdf_file }}"
method <- "{{ method }}"


X <- as.data.frame(t(read.table(profile.table,header = T,sep = "\t",row.names=1,check.names=F,quote = "")))
X1 <- as.data.frame(t(X))
group=read.table(group.file,header=F,row.names=1,sep="\t",check.names=F)
X <- X[rownames(group),]
X1 <- X1[,rownames(group)]
X <- X[which(complete.cases(X)),]
X1 <- X1[which(complete.cases(X1)),]
env <- group
envname <- colnames(env)
n <- length(envname)
envname_lables=as.data.frame(colnames(env))
rownames(envname_lables)=colnames(env)
d <- as.dist(vegdist(X,method=method))
ttable <- adonis(d~V2,data=env,permutations = 999)
value_R2 <- ttable$aov.tab[envname,"R2"]
value_R2 <- round(value_R2,3)
value_p <- ttable$aov.tab[envname,"Pr(>F)"]
value_p <- round(value_p,3)
color_list = group2corlor(group)
sample_colors = color_list[[1]]
group_colors = color_list[[2]]
group_names = color_list[[3]]
group = color_list[[4]]
g = unique(group)
sample.list <- group[,1]
group_num = length(group_colors)
pdf(file=pdf.file,11,8.5)
par(mar=c(4.1,5.1,4.1,2.1))

if(nrow(X1)<=1){
    plot(0,type='n')
    text(1,0,'no item for plot')
}else{

	max_group_name_length = max(mapply(nchar,as.character(sample.list)))
	g = unique(group)
	library("ade4")
	Xdist=dist(t(X1))
	X.dudi=dudi.pca(t(X1),center=F,scale=T,scan=F)
	len=c()
	con=X.dudi$eig/sum(X.dudi$eig)*100
	con=round(con,2)

	sample_num = ncol(X1)
	if(sample_num < 10){
		cex = 3
	}else if(sample_num < 20){
		cex = 2.2
	}else{
		cex = 1.2
	}

	nf<-layout(matrix(c(1,1,3,1,1,3,1,1,3,2,2,4,2,2,4),5,3,byrow=TRUE))

	plot(X.dudi$li,col=sample_colors,pch=19,
		 xlab=paste("PCA1(",con[1],"%)",sep=""),
		 ylab=paste("PCA2(",con[2],"%)",sep=""),
		 cex=cex,cex.axis=1.5,cex.lab=2)

	par(mar=c(4.1,5.1,0,2.1))
	Y=rbind(X.dudi$li[1]$Axis1,as.character(group[,1]))
	Y=t(Y)
	Y=as.data.frame(Y)
	rownames(Y) = colnames(X1)
	colnames(Y)=c("pc","time")
	Y$pc=as.numeric(as.character(Y$pc))
	levels=rev(g[,1])
	Y$time=factor(Y$time,levels)
	#boxplot(pc ~ time, data = Y, col = rev(group_colors), horizontal=T,outline=T,cex.lab=1.6,cex.axis=1.2,xaxt="n")

		if (max_group_name_length<=10 && group_num <= 2){
		  boxplot(pc ~ time, data = Y, col = rev(group_colors), horizontal=T,outline=T,cex.lab=1.6,cex.axis=1.2,xaxt="n")
		}else if(max_group_name_length<=8 && group_num <= 3){
		  boxplot(pc ~ time, data = Y, col = rev(group_colors), horizontal=T,outline=T,cex.lab=1.6,cex.axis=1.2,xaxt="n")
		}else if(max_group_name_length<=6 && group_num <= 4){
		  boxplot(pc ~ time, data = Y, col = rev(group_colors), horizontal=T,outline=T,cex.lab=1.6,cex.axis=1.2,xaxt="n")
		}else if(max_group_name_length<5 && group_num <= 5){
          boxplot(pc ~ time, data = Y, col = rev(group_colors), horizontal=T,outline=T,cex.lab=1.6,cex.axis=1.2,xaxt="n")
        }else{
		  srt.pcoa = 45
		  boxplot(pc ~ time, data = Y, col = rev(group_colors), horizontal=T,outline=T,cex.lab=1.6,cex.axis=1.2,xaxt="n",yaxt="n")
		  text(labels = attr(Y$time,"levels"),x = rep(min(Y$pc)*1.08, length(attr(Y$time,"levels"))), y = (1 : length(attr(Y$time,"levels"))),  srt = srt.pcoa, xpd = T, adj = 0.4)
		}

	if (length(table(sample.list))==2){
	  p_value_plot1=wilcox.test(X.dudi$li[,1][sample.list==names(table(sample.list))[1]],X.dudi$li[,1][sample.list==names(table(sample.list))[2]])$p.value
	  legend("bottomright", paste0("p=", format(p_value_plot1,scientific=TRUE,digit=5)))
	}else{
	  p_value_plot1=kruskal.test(X.dudi$li[,1],sample.list)$p.value
	  legend("bottomright",paste0("p=",round(p_value_plot1,3)))
	}


	par(mar=c(4.1,0,3.1,5.1))
	Y1=rbind(X.dudi$li[2]$Axis2,as.character(group[,1]))
	Y1=t(Y1)
	Y1=as.data.frame(Y1)
	rownames(Y1) = colnames(X1)
	colnames(Y1)=c("pc1","time1")
	Y1$pc1=as.numeric(as.character(Y1$pc1))
	levels=g[,1]
	Y1$time1=factor(Y1$time1,levels)
	#boxplot(pc1 ~ time1, data = Y1, col = group_colors,horizontal=F,outline=T,cex.lab=1.6,cex.axis=1.2,yaxt="n")



	if (max_group_name_length<=10 && group_num <= 2){
		  boxplot(pc1 ~ time1, data = Y1, col = group_colors,horizontal=F,outline=T,cex.lab=1.6,cex.axis=1.2,yaxt="n")
	}else if(max_group_name_length<=8 && group_num <= 3){
	  boxplot(pc1 ~ time1, data = Y1, col = group_colors,horizontal=F,outline=T,cex.lab=1.6,cex.axis=1.2,yaxt="n")
	}else if(max_group_name_length<=6 && group_num <= 4){
	  boxplot(pc1 ~ time1, data = Y1, col = group_colors,horizontal=F,outline=T,cex.lab=1.6,cex.axis=1.2,yaxt="n")
	}else if(max_group_name_length<5 && group_num <= 5){
      boxplot(pc1 ~ time1, data = Y1, col = group_colors,horizontal=F,outline=T,cex.lab=1.6,cex.axis=1.2,yaxt="n")
    }else{
	  srt.pcoa = 60
	  #boxplot(pc1 ~ time1,data = Y1, pch = 20, col = rev(group_colors), notch = F, cex.axis = 0.8,xaxt = "n");
	  boxplot(pc1 ~ time1, data = Y1, col = group_colors,horizontal=F,outline=T,cex.lab=1.6,cex.axis=1.2,xaxt = "n")
	  text(labels =  attr(Y1$time1,"levels"), x = (1 : length(attr(sample.list,"levels"))), y = rep(min(Y1$pc1)*1.2,length(attr(sample.list,"levels"))), srt = srt.pcoa, xpd = T, adj = 1)
	}

	if (length(table(sample.list))==2){
	  p_value_plot2=wilcox.test(X.dudi$li[,2][sample.list==names(table(sample.list))[1]],X.dudi$li[,2][sample.list==names(table(sample.list))[2]])$p.value
	  legend("bottomright",paste0("p=",round(p_value_plot2,3)))
	}else{
	  p_value_plot2=kruskal.test(X.dudi$li[,2],sample.list)$p.value
	  legend("bottomright",paste0("p=",round(p_value_plot2,3)))
	}

	plot(0, xaxt='n', yaxt='n',type='n',xlab='',bty='n')
	legend("top",legend=group_names,col=group_colors,pch=15,cex=1.3,pt.cex=5,x.intersp=3,y.intersp=2,horiz=F,ncol = ceiling(length(group_colors)/6))

	write.csv(X.dudi$li,file=paste(substr(pdf.file,0,nchar(pdf.file)-4),"_point_inf.csv",sep = ""),fileEncoding="utf-8",quote = F)
}
mtext(paste("Adonis test:","p=",value_p," R=",value_R2),3,line=1)
dev.off()
