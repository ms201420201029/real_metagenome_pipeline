source("{{ tool_default_dir }}/labels2colors.R")

library(vegan)
treeplot <- function(dist, grp, grpcol, ...)
{
  tree <- hclust(dist)
  treeline <- function(pos1, pos2, height, col1, col2)
  {
    meanpos = (pos1[1] + pos2[1]) / 2
    segments(y0 = pos1[1] - 0.4, x0 = -pos1[2], y1 = pos1[1] - 0.4, x1 = -height,  col = col1, lwd = 2)
    segments(y0 = pos1[1] - 0.4, x0 = -height,  y1 = meanpos - 0.4, x1 = -height,  col = col1, lwd = 2)
    segments(y0 = meanpos - 0.4, x0 = -height,  y1 = pos2[1] - 0.4, x1 = -height,  col = col2, lwd = 2)
    segments(y0 = pos2[1] - 0.4, x0 = -height,  y1 = pos2[1] - 0.4, x1 = -pos2[2], col = col2, lwd = 2)
  }
  plot(0, type = "n", xaxt = "n", yaxt = "n", frame.plot = F, xlab = "", ylab = "",
       ylim = c(0, length(tree$order)),
       xlim = c(-max(tree$height), 0))
  axis(1)
  mtext("bray distance",side = 1,font=2,line = 2)
  meanpos = matrix(rep(0, 2 * length(tree$order)), ncol = 2)
  meancol = rep(0, length(tree$order))
  for (step in 1:nrow(tree$merge))
  {
    if(tree$merge[step, 1] < 0){
      pos1 <- c(which(tree$order == -tree$merge[step, 1]), 0)
      col1 <- grpcol[grp[tree$labels[-tree$merge[step, 1]]]]
    }else {
      pos1 <- meanpos[tree$merge[step, 1], ]
      col1 <- meancol[tree$merge[step, 1]]
    }
    if(tree$merge[step, 2] < 0){
      pos2 <- c(which(tree$order == -tree$merge[step, 2]), 0)
      col2 <- grpcol[grp[tree$labels[-tree$merge[step, 2]]]]
    }else {
      pos2 <- meanpos[tree$merge[step, 2], ]
      col2 <- meancol[tree$merge[step, 2]]
    }
    height <- tree$height[step]
    treeline(pos1, pos2, height, col1, col2)
    meanpos[step, ] <- c((pos1[1] + pos2[1]) / 2, height)
    if (col1 == col2){
      meancol[step] <- col1
    }else {
      meancol[step] <- "grey"
    }
  }
  
  legend("topleft", pch = 15, col = grpcol, legend = names(grpcol), bty = "n", cex = 1.5)
  tree$order
}
topbarplot <- function(profile,title, number = 6)
{
  if(nrow(profile)<number){
	number=nrow(profile)
  }else if(nrow(profile)>number){
	number=20
  }
  rowsums <- rowSums(profile)
  profile <- as.matrix(profile[order(-rowsums)[1:number], ])
  if(nrow(profile)>6){
  	col = cols_brewer[1:nrow(profile)]
	names(col)=rownames(profile)
  }else{
	col <- pathcolors[rownames(profile)]
  }
#  Others  <- 1 - apply(profile, 2, sum)
#  profile <- rbind(profile, Others)
  barplot(profile, col = c(col,"#FFFFFF"), space = 0.25, width = 0.8, horiz = T, xaxt = "n", las = 1, ylim = c(0, ncol(profile)),cex.names=0.9)
  mtext(title, side = 3, line = 1, cex = 2)
#  mtext("KEGG Level1 Relative Abundance", side = 1, line = 1, cex = 2)
  col
}


kegg_level1_profile <- "{{ profile_table }}"
groupfile <- "{{ group_file }}"
outfilepdf <- "{{ outfilepdf }}"
title = "{{ title }}"
data <- read.table(kegg_level1_profile,sep="\t",header = T,quote="",check.names = F,row.names = 1)
pregroup <- read.table(groupfile, header = F, check.names = F, row.names = 1)
data <- data[,rownames(pregroup)]
color_list = group2corlor(pregroup)
sample_colors=color_list[[1]]
group_colors= color_list[[2]]
group_names = color_list[[3]]


names(group_colors) <- group_names

group <- as.vector(pregroup[,1])
names(group) <- rownames(pregroup)

pdf(outfilepdf,height = 8, width = 16)

dist = vegdist(t(data))
layout(t(rep(c(1,2,3),c(1,4,2))))
par(mar = c(5,3,5,0))
data.order <- treeplot(dist, group, group_colors)
data <- data[, data.order]
par(mar = c(5,7,5,0))
specol <- topbarplot(data,title)
par(mar = c(5,0,5,0))
plot(0, type = "n", xaxt = "n", yaxt = "n", bty ="n", xlab = "", ylab = "")
legend("left", pch = 15, col = specol, legend = names(specol), bty = "n", cex = 2)
dev.off()
