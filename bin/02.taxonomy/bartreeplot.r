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
  tree$order
}
topbarplot <- function(profile, number = 10)
{
  palette <- c("red",        "gray",          "cornflowerblue", "chartreuse3",
	       "yellow",     "honeydew4",     "indianred4",     "khaki",
	     "lightblue1", "lightseagreen", "lightslateblue", "magenta",
	     "blue",       "orange2",       "purple",         "black");
  color <- colorRampPalette(palette, interpolate = "spline", space = "Lab");
  col <- color(number + 1)
  rowsums <- rowSums(profile)
  profile <- as.matrix(profile[order(-rowsums)[1:number], ])
  Others  <- 1 - apply(profile, 2, sum)
  profile <- rbind(profile, Others)
  barplot(profile, col = col, space = 0.25, width = 0.8, horiz = T, xaxt = "n", las = 1, ylim = c(0, ncol(profile)))
  mtext(paste(number, "Main Species in Samples"), side = 3, line = 1, cex = 2)
  specol <- col
  names(specol) <- rownames(profile)
  specol
}
args <- commandArgs(T)
if (length(args) != 3){stop("Rscript $0 profile group output.pdf")}
data <- read.table(args[1], head = T, check.names = F)
pregroup <- read.table(args[2], head = F, check.names = F, row.names = 1)
pdf(args[3], width = 15)
group <- as.vector(pregroup[,1])
names(group) <- rownames(pregroup)
grpcol <- c("orange", "royalblue", "seagreen", "lightpink")
names(grpcol) <- levels(pregroup[, 1])
dist = dist(t(data))
layout(t(c(1,2,2,2,3)))
par(mar = c(5,5,5,0))
data.order <- treeplot(dist, group, grpcol)
data <- data[, data.order]
par(mar = c(5,3,5,0))
specol <- topbarplot(data)
par(mar = c(5,0,5,0))
plot(0, type = "n", xaxt = "n", yaxt = "n", bty ="n", xlab = "", ylab = "")
legend("left", pch = 15, col = specol, legend = names(specol), bty = "n", cex = 1.5)
dev.off();
