args <- commandArgs(T)
if(length(args)!=6){
  if(args[5]!="y"){
	stop("Usage: Rscript **.R profile diff group pdf log add")
  }
}
profile_all <- read.table(args[1],head = T,sep="\t",row.names=1,quote="",check.names = F)
pvalue      <- read.table(args[2],head = T,sep="\t",quote="",check.names = F)
group       <- read.table(args[3],head = F,sep="\t",quote="",check.names = F)

boxplot_forGroup <- function(Mat, Grp=as.factor(rep("A",nrow(Mat))), col, at=1:nrow(Mat), width=0.7, boxwex=0.6/length(levels(Grp[,2])), mean=T, mean.pch=3, mean.col="red", mean.cex=1, mean.value=matrix(ncol=1,nrow=1), ylab="Abundance", srt=45, yaxs="r", ...){
  nBox <- length(levels(Grp[,2]))
  if(is.vector(col)) col = matrix(rep(col, nBox), ncol = nBox)
  atRel <- seq(from=(boxwex-width)/2, to=(width - boxwex)/2, length.out=nBox)
  xlim <- range(at) + c(-0.5 * width, 0.5 * width)
  ylim <- range(Mat)
  ylim_max <- max(Mat)
  ylim_min <- min(Mat)
  lower_limit <- ylim_min - (ylim_max - ylim_min)/12
  #upper_limit <- ylim_max + (ylim_max - ylim_min) / 8
  #ylim <- c(lower_limit, upper_limit)
  for(i in 1:nBox){
    grp <- levels(Grp[,2])[i]
    Mat.forPlot <- Mat[, Grp[which(Grp[,2] == grp),1]]
    if(i == 1) {
      boxplot(t(Mat.forPlot), col=col[i,], at=at+atRel[i], boxwex=boxwex, xaxt="n", add=F, ylab=ylab, xlim=xlim, ylim=ylim, cex.lab=1.8, ...)
    }else{
      boxplot(t(Mat.forPlot), col=col[i,], at=at+atRel[i], boxwex=boxwex, xaxt="n", add=T, ...)
    }
    if(!is.na(mean.value[1,1])){
	  Mat.forPlot.mean = mean.value[i,]
	}else{
	  Mat.forPlot.mean = apply(Mat.forPlot, 1, mean)
	}
    if(mean) points(y=Mat.forPlot.mean, x=at+atRel[i], col=mean.col, pch=mean.pch, cex=mean.cex)
  }
  axis(1, labels=F, at=at)
  text(labels=row.names(Mat), x=at, y=rep(lower_limit, length(at)), srt=srt, xpd=T, adj=1, cex=1)
  legend("topright", legend = levels(Grp[,2]), col = col[, 1], pch = 15, bty = "n", cex = 1.2)
}

boxplot_for_subgroup <- function(Mat, Grp=as.factor(rep("A",nrow(Mat))), col, at=1:nrow(Mat), width=0.7, boxwex=0.6/length(levels(Grp[,2])), mean=T, mean.pch=3, mean.col="red", mean.cex=1, subrow=c(1:nrow(Mat)), ...){
  nBox <- length(levels(Grp[,2]))
  if(is.vector(col)) col = matrix(rep(col, nBox), ncol = nBox)
  atRel <- seq(from=(boxwex-width)/2, to=(width - boxwex)/2, length.out=nBox)
  xlim <- range(at) + c(-0.5 * width, 0.5 * width)
  ylim <- range(Mat)
  ylim_max <- max(Mat)
  ylim_min <- min(Mat)
  lower_limit <- ylim_min - (ylim_max - ylim_min)/6
  #upper_limit <- ylim_max + (ylim_max - ylim_min) / 6
  #ylim <- c(lower_limit, upper_limit)
  for(i in 1:nBox){
    grp <- levels(Grp[,2])[i]
    Mat.forPlot <- Mat[, Grp[which(Grp[,2] == grp),1]]
    if(i == 1) {
      boxplot(t(Mat.forPlot), col=col[i,], at=at+atRel[i], boxwex=boxwex, xaxt="n", add=F, ylim=ylim, xlim=xlim, cex.lab=1.8, xaxs="i", ...)
    }else{
      boxplot(t(Mat.forPlot), col=col[i,], at=at+atRel[i], boxwex=boxwex, xaxt="n", add=T, ...)
    }
    Mat.forPlot.mean = apply(Mat.forPlot, 1, mean)
    if(mean) points(y=Mat.forPlot.mean, x=at+atRel[i], col=mean.col, pch=mean.pch, cex=mean.cex)
  }
  axis(1, labels=F, at=at)
  text(labels=subrow, x=at, y=rep(lower_limit, length(at)), xpd=T, adj=1, cex=1.6)
  #text(labels=subrow, x=at, y=rep(lower_limit+lower_limit/6, length(at)), xpd=T, adj=1, cex=1.6)
}
enrich <- levels(pvalue[, ncol(pvalue)])
pdf(args[4], width = 14, height = 6*length(enrich))
if(args[5]=="n"){
  m <- 0
  n <- 0
  layout_matrix <- matrix(ncol=1,nrow=1)
  for(i in 1:length(enrich)){
	select_species <- as.vector(pvalue[which(pvalue[, ncol(pvalue)] == enrich[i]), 1])      #获得属于各组的物种
	if(length(select_species) > 0){      #判断是否需要画大图
	  m <- n + 1
	}else{
	  m <- n
	}
    profile <- profile_all[select_species, ]
    sub_group <- as.vector(group[which(group[,2] == enrich[i]),1])      #获得属于各组的样本名
    profile_sortByMedian <- profile[order(apply(profile[sub_group], 1, median), decreasing = T), ]      #按照中位值排序
    profile_sortByMedian_top20 <- profile_sortByMedian[1:min(20, nrow(profile_sortByMedian)),]
  	profile_plot <- profile_sortByMedian_top20
	cutoff <- (max(profile_plot[sub_group])-min(profile_plot[sub_group]))/10
    selected_row <- as.vector(which(apply(profile_plot[sub_group], 1, function(row) max(row)<cutoff)))      #获得最高值小于cutoff的物种的下标
	if(length(selected_row) > 0){      #判断是否需要画小图
	  n <- m + 1
	}else{
	  n <- m
	}
	sub_matrix <- matrix(unlist(rep(list(c(m,m),c(n,m)),c(20-length(selected_row),length(selected_row)))),nrow=2)      #生成每个组的layout值
    if(!is.na(layout_matrix)[1,1]){
      layout_matrix <- rbind(layout_matrix,sub_matrix)
    }else{
      layout_matrix <- sub_matrix
    }
  }
  if(args[6]=="add"){      #判断所有大图是否添加小图
	final_layout <- layout_matrix
  }else{
	final_layout <- c(1:length(enrich))
  }
  layout(final_layout)
  for(i in 1:length(enrich)){
	select_species <- as.vector(pvalue[which(pvalue[, ncol(pvalue)] == enrich[i]), 1])
    profile <- profile_all[select_species, ]
    sub_group <- as.vector(group[which(group[,2] == enrich[i]),1])
    profile_sortByMedian <- profile[order(apply(profile[sub_group], 1, median), decreasing = T), ]
    profile_sortByMedian_top20 <- profile_sortByMedian[1:min(20, nrow(profile_sortByMedian)),]
	profile_plot <- profile_sortByMedian_top20
	cutoff <- (max(profile_plot[sub_group])-min(profile_plot[sub_group]))/10
	selected_row <- as.vector(which(apply(profile_plot[sub_group], 1, function(row) max(row)<cutoff)))
	if(length(select_species) > 0){
      par(mar=c(16, 6, 1, 1), xpd=T)
	  boxplot_forGroup(profile_plot, group, col=topo.colors(6), pch=20, range=0)
	}
	if(length(selected_row) > 0 && args[6]=="add"){
	  par(mar = c(c(16, 6)*length(selected_row)/nrow(profile_plot), 1, 1), xpd = T)
	  boxplot_for_subgroup(profile_plot[selected_row,], group, col=topo.colors(6), pch=20, subrow=selected_row, range=0)
	}
  }
}else if(args[5]=="y"){
  m <- 0
  for(i in 1:length(enrich)){      #设置作图的layout
	select_species <- as.vector(pvalue[which(pvalue[, ncol(pvalue)] == enrich[i]), 1])
	if(length(select_species) > 0) m <- m+1
  }
  layout(c(1:m))
  for(i in 1:length(enrich)){
	select_species <- as.vector(pvalue[which(pvalue[, ncol(pvalue)] == enrich[i]), 1])
	if(length(select_species) < 1){
	  next
	}
    profile <- profile_all[select_species, ]
    sub_group <- as.vector(group[which(group[,2] == enrich[i]),1])
    profile_sortByMedian <- profile[order(apply(profile[sub_group], 1, median), decreasing=T), ]
    profile_sortByMedian_top20 <- profile_sortByMedian[1:min(20, nrow(profile_sortByMedian)),]
    means <- matrix(ncol=1,nrow=1)
	for(i in 1:length(levels(group[,2]))){      #求平均值
	  mean <- t(as.matrix(as.vector(apply(as.matrix(profile_sortByMedian_top20[, group[which(group[,2] == levels(group[,2])[i]),1]]), 1, mean)),nrow=1))
	  if(!is.na(means)[1,1]){
		means <- rbind(means,mean)
	  }else{
		means <- mean
	  }
	}
	means <- log10(means)
  	profile_plot <- log10(profile_sortByMedian_top20)
  	min_num <- min(profile_plot[profile_plot!=-Inf])      #将上一步因取log值获得的-Inf改为某个值(后续两步)
  	max_num <- max(profile_plot)
  	profile_plot[profile_plot==-Inf] <- min_num - (max_num - min_num)/16
	par(mar = c(16, 6, 1, 1), xpd = T)
	boxplot_forGroup(profile_plot, group, col=topo.colors(6), pch=20, mean.value=means, range=0)
  }
}else{
  stop(paste("please select \"y\" or \"n\" for the fifth parameter !"))
}
dev.off()

