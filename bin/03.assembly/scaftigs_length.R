args <- commandArgs(T)
len <- read.table(args[1], head = T, check.names = F, row.names = 1)
is.overflow = max(len) > 10000
len[which(len[, 1] > 10000), ] = 10000
pdf(args[2])
if (is.overflow){
  hist.result <- hist(len[, 1], breaks = 50, xlim = c(500, 10000), main = "Histogram of Length of Scaftigs", xlab = "Length of Scaftigs", ylab = "Number of Scaftigs", col = "lightblue")
  text(x = 10000, y = hist.result$counts[length(hist.result$counts)], labels = "length > 10000              ", pos = 3, offset = 0.5)
}else {
  hist.result <- hist(len[, 1], breaks = 50, main = "Histogram of Length of Scaftigs", xlab = "Length of Scaftigs", ylab = "Number of Scaftigs", col = "lightblue")
}
dev.off()
