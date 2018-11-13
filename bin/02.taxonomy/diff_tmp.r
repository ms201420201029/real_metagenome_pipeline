args <- commandArgs(T)
profile.all <- read.table(args[1], head = T, check.names = F)
group       <- read.table(args[2], head = F, check.names = F)
pvalue      <- read.table(args[3], head = F, check.names = F)

enrich <- levels(pvalue[, 4])
profile.a <- profile.all[as.vector(pvalue[which(pvalue[, 4] == enrich[1]), 1]), ]
profile.b <- profile.all[as.vector(pvalue[which(pvalue[, 4] == enrich[2]), 1]), ]
profile.a.sortByMedian <- profile.a[order(apply(profile.a, 1, median), decreasing = T), ]
profile.b.sortByMedian <- profile.b[order(apply(profile.b, 1, median), decreasing = T), ]
profile.a.sortByMedian.top20 <- profile.a.sortByMedian[1:min(20, nrow(profile.a.sortByMedian)), ]
profile.b.sortByMedian.top20 <- profile.b.sortByMedian[1:min(20, nrow(profile.b.sortByMedian)), ]
profile.a.forPlot <- profile.a.sortByMedian.top20
profile.b.forPlot <- profile.b.sortByMedian.top20

boxplot.forGroup <- function(Mat, Grp = as.factor(rep("A", nrow(Mat))), col, at = 1:nrow(Mat), width = 0.7, boxwex = 0.6 / length(levels(Grp)) , mean = TRUE, mean.pch = 3, mean.col = "red", mean.cex = 1, ylab = "Abundance", srt = 45, ...) {
  nBox <- length(levels(Grp))
  if (is.vector(col)) col = matrix(rep(col, nBox), ncol = nBox)
  atRel <- seq(from = (boxwex - width) / 2, to = (width - boxwex) / 2, length.out = nBox)
  xlim <- range(at) + c(-0.5 * width, 0.5 * width)
  ylim <- range(Mat)

  for (i in 1:nBox){
    grp <- levels(Grp)[i]
    Mat.forPlot <- Mat[, which(Grp == grp)]
    if(i == 1) {
      boxplot(t(Mat.forPlot), col = col[i, ], at = at + atRel[i], boxwex = boxwex, xaxt = "n", add = F, ylab = ylab, xlim = xlim, ylim = ylim, cex.lab = 2, ...)
    }else {
      boxplot(t(Mat.forPlot), col = col[i, ], at = at + atRel[i], boxwex = boxwex, xaxt = "n", add = T, ...)
    }
    Mat.forPlot.mean = apply(Mat.forPlot, 1, mean)
    if(mean) points(y = Mat.forPlot.mean, x = at + atRel[i], col = mean.col, pch = mean.pch, cex = mean.cex)
  }
  axis(1, labels = F, at = at)
  text(labels = row.names(Mat), x = at, y = rep((min(Mat) - max(Mat)) / 10, length(at)), srt = srt, xpd = T, adj = 1, cex = 0.8)
  legend("topright", legend = levels(Grp), col = col[, 1], pch = 15, bty = "n", cex = 2)
}

pdf(args[4], width = 10, height = 10)
layout(c(1, 2))
par(mar = c(10, 10, 1, 1), xpd = T)
boxplot.forGroup(profile.a.forPlot, group[, 2], col = c("royalblue", "orange"), pch = 20, range = 0)
par(mar = c(10, 10, 1, 1), xpd = T)
if(is.na(min(profile.b.forPlot))){
dev.off()
stop("profile.b.forPlot is null")
}
boxplot.forGroup(profile.b.forPlot, group[, 2], col = c("royalblue", "orange"), pch = 20, range = 0)
dev.off()


