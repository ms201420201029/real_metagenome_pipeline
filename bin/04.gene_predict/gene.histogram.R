args <- commandArgs(T)
len <- read.table(args[1], head = T, check.names = F, row.names = 1)
is.overflow = max(len) > 3000
len[which(len[, 1] > 3000), ] = 3000
len = as.data.frame(len[which(len[, 1] > 100), ])
pdf(args[2])
if (is.overflow){
  hist.result <- hist(len[, 1], breaks = 50, xlim = c(100, 3000), main = "Histogram of Length of Genes", xlab = "Length of Genes", ylab = "Number of Genes", col = "lightblue")
  text(x = 3000, y = hist.result$counts[length(hist.result$counts)], labels = "length > 3000             ", pos = 3, offset = 0.5)
}else {
  hist.result <- hist(len[, 1], breaks = 50, main = "Histogram of Length of Genes", xlab = "Length of Genes", ylab = "Number of Genes", col = "lightblue")
}
dev.off()
