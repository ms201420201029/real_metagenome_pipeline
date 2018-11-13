source("{{ tool_default_dir }}/labels2colors.R")
profile.table <- "{{ profile_table }}"
group.file <- "{{ group_file }}"
pdf.file = "{{ pdf_file }}"
method <- "{{ method }}"

Dist <- function(profile.data, method){
  dist.data <- tryCatch(dist(profile.data, method = method), error = function(e) {NA});
  if (class(dist.data) == "dist"){
    dist.data;
  }else {
    library(vegan);
    vegdist(profile.data, method = method);
  }
}

profile.data <- read.table(profile.table, check.names = F, header = T,row.names = 1,quote="",sep="\t")
sample.group <- read.table(group.file,   check.names = F, row.names = 1)
profile.data <- profile.data[,rownames(sample.group)]
dist.data    <- Dist(t(profile.data), method = method)
sample.list <- sample.group[,1]

library("ade4");
library("car");
pcoa <- dudi.pco(dist.data, scannf = F, nf = 2);
pdf(file = pdf.file,11,8.5)
layout(matrix(c(1,1,1,3,
		1,1,1,3,
		1,1,1,3,
		2,2,2,4,
		2,2,2,4), byrow = T, ncol = 4));
if (length(attr(sample.list,"levels")) > 20) {
  col.sample <- topo.colors(length(attr(sample.list,"levels")));
}else {
  col.sample <- cols_brewer
}
par(mar=c(4.1,5.1,4.1,2.1))
pcoa.eig <- signif(pcoa$eig, digits = 3);
if (length(sample.list) <= 10) {
  pcoa.cex <- 4
}else if (length(sample.list) <= 30){
  pcoa.cex <- 2
}else {
  pcoa.cex <- 1
}

# add circle
plot(pcoa$li, pch = 20, col = col.sample[sample.list],
	  main = paste("PCoA by distance of", method, "between samples"),
	  xlab = paste("PCoA1: ", signif(pcoa.eig[1]/sum(pcoa$eig) * 100,digits=3), "%", sep = ""),
	  ylab = paste("PCoA2: ", signif(pcoa.eig[2]/sum(pcoa$eig) * 100,digits=3), "%", sep = ""),
	  cex = pcoa.cex,xlim=c(min(pcoa$li[1])-0.5,max(pcoa$li[1])+0.5),
	  ylim=c(min(pcoa$li[2])-0.5,max(pcoa$li[2])+0.5))

dataEllipse(pcoa$li[1]$A1,pcoa$li[2]$A2,sample.list,
	  col=rep("cadetblue1",time = length(attr(sample.list,"levels"))),
	  pch=19,group.labels=rep("",time = length(attr(sample.list,"levels"))),
	  level=.95, fill.alpha=0.1,center.cex=0,add = TRUE,plot.points=FALSE)     
	 
	 
if (length(sample.list) <= 10) {
  for (i in 1 : length(sample.list)){
	text(x = pcoa$li[i, 1], y = pcoa$li[i, 2], labels = labels(dist.data)[i], xpd = T)
  }
}

###########
par(mar=c(4.1,5.1,0,2.1))
boxplot(pcoa$li[,1] ~ sample.list, pch = 20, col = col.sample, notch = F, horizontal = T, cex.axis = 0.8);
if (length(table(sample.list))==2){
  p_value_plot1=wilcox.test(pcoa$li[,1][sample.list==names(table(sample.list))[1]],pcoa$li[,1][sample.list==names(table(sample.list))[2]])$p.value
  legend("bottomright",paste0("p=",round(p_value_plot1,3)))
}else{
  p_value_plot1=kruskal.test(pcoa$li[,1],sample.list)$p.value
  legend("bottomright",paste0("p=",round(p_value_plot1,3)))
}

###########
par(mar=c(4.1,0,3.1,5.1))
max_group_name_length = max(mapply(nchar,as.character(sample.list)))
group_num = length(attr(sample.list,"levels"))

if (max_group_name_length<=10 && group_num <= 2){
	boxplot(pcoa$li[,2] ~ sample.list, pch = 20, col = col.sample, notch = F, cex.axis = 0.8);
}else if(max_group_name_length<=8 && group_num <= 3){
	boxplot(pcoa$li[,2] ~ sample.list, pch = 20, col = col.sample, notch = F, cex.axis = 0.8);
}else if(max_group_name_length<=6 && group_num <= 4){
	boxplot(pcoa$li[,2] ~ sample.list, pch = 20, col = col.sample, notch = F, cex.axis = 0.8);
}else if(max_group_name_length<=5 && group_num <= 5){
	boxplot(pcoa$li[,2] ~ sample.list, pch = 20, col = col.sample, notch = F, cex.axis = 0.8);
}else{
	srt.pcoa = 60
	boxplot(pcoa$li[,2] ~ sample.list, pch = 20, col = col.sample, notch = F, cex.axis = 0.8,xaxt = "n");
    text(labels = attr(sample.list,"levels"), x = (1 : length(attr(sample.list,"levels"))), y = rep(min(pcoa$li[,2])*1.1,length(attr(sample.list,"levels"))), srt = srt.pcoa, xpd = T, adj = 1)
}

if (length(table(sample.list))==2){
  p_value_plot2=wilcox.test(pcoa$li[,2][sample.list==names(table(sample.list))[1]],pcoa$li[,2][sample.list==names(table(sample.list))[2]])$p.value
  legend("bottomright",paste0("p=",round(p_value_plot2,3)))
}else{
  p_value_plot2=kruskal.test(pcoa$li[,2],sample.list)$p.value
  legend("bottomright",paste0("p=",round(p_value_plot2,3)))
}

###########
plot(0, xaxt='n', yaxt='n',type='n',xlab='',bty='n')
legend("top",legend=attr(sample.list,"levels"),col=col.sample,,pch=15,cex=1.3,pt.cex=5,
	 x.intersp=3,y.intersp=2,horiz=F,ncol = ceiling(length(attr(sample.list,"levels"))/6))
dev.off();