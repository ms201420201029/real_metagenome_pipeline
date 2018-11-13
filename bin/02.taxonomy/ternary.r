args <- commandArgs("T")
profile <- read.table(args[1], head = T, check.names = F);
group <- read.table(args[2], head = F, check.names = F, row.names = 1)
colors <- c("orange", "royalblue", "seagreen", "lightpink")
#pch <- substr(levels(Positions), 1, 1)
rowsum <- apply(profile, 1, sum)
profile <- profile[rev(order(rowsum))[1:2], , drop = F]
other <- 1 - apply(profile, 2, sum)
profile <- rbind(profile, other)
rownames(profile)[3] = "Other"
if (ncol(profile) < 10) {
  cex = 3
}else if (ncol(profile) < 30) {
  cex = 2
}else {
  cex = 1
}
pdf(args[3], height = 7, width = 10)
library(vcd)
ternaryplot(
  t(profile),
  pch = 20,
  col = colors[as.numeric(group[, 1])],
  main = paste("Two Main", args[4], "in Samples"),
  labels = "outside",
  grid = 'dashed',
  cex = cex
)
pch = 20
grid_legend(0.8, 0.7, pch, colors, levels(group[, 1]),  title = "Samples")
dev.off()
