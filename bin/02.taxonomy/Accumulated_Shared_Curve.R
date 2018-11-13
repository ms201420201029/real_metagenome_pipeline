arg   <- commandArgs("T");
type  <- arg[2];
accum <- read.table(paste(arg[1], ".accum.tab", sep = ""), header = T, check.names = F);
share <- read.table(paste(arg[1], ".share.tab", sep = ""), header = T, check.names = F);

pdf(paste(arg[1], ".accum_share.pdf", sep = ""));
axis.x    <- as.numeric(colnames(accum));
width.box <- (axis.x[2] - axis.x[1]) * 0.8;
lim.x     <- range(axis.x) + c(-width.box, width.box);
boxplot(accum, at = axis.x, boxwex = width.box, pch = 20, cex = 0.8, cex.axis = 0.8, xlim = lim.x,
	col  = c("lightcyan", rep("lightgreen", ncol(accum) - 1)),
	ylim = range(accum, share),
	main = paste("Accumulated and shared curve of", type, "profile"),
	xlab = "Number of samples",
	ylab = paste("Number of", type));
boxplot(share[,-1], at = axis.x[-1], boxwex = width.box, pch = 20, cex = 0.8, col = "lightblue", xaxt = "n", yaxt = "n", add = T);
lines(apply(accum, 2, median) ~ axis.x, col = "green");
lines(apply(share, 2, median) ~ axis.x, col = "blue");
legend("right", col = c("green", "blue"), pch = 15, bty = "n",
       legend = c(paste("Number of", type, "in all samples"),
	          paste("Number of", type, "in any sample")));
dev.off();
