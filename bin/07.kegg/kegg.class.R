args <- commandArgs(T)
data.a <- read.table(paste(args[1], ".path.class", sep = ""), head = T, check.names = F, sep = "\t")
data.b <- read.table(paste(args[2], ".path.class", sep = ""), head = T, check.names = F, sep = "\t")
data.merge <- merge(data.a, data.b, by = c("CLASS", "Pathway"), all = T, sort = T)
data.merge[is.na(data.merge)] <- 0;

pdf(args[3], height = 15, width = 15);
layout(c(1,2))
col = c("royalblue","orange");

par(mar = c(10, 5, 1, 1))
barplot(t(data.merge[, c("num.x", "num.y")]), col = col, beside = T, ylab = "Number in each Category")
legend("right", legend = args[1:2], col = col, pch = 15);
legend("topright", legend = levels(data.merge[, "CLASS"]), text.col = levels(as.factor(as.numeric(data.merge[, "CLASS"]))))
text(labels = data.merge[, "Pathway"], col = as.numeric(data.merge[, "CLASS"]), srt = 45, xpd = T, adj = 1, cex = 0.7,
		x = 3 * (1:nrow(data.merge)) - 1,
		y = -rep(max(data.merge[, c("num.x", "num.y")]) / 50, nrow(data.merge)))

barplot(t(data.merge[, c("precent.x", "precent.y")]), col = col, beside = T, ylab = "Percentage in each Category(%)")
legend("right", legend = args[1:2], col = col, pch = 15)
legend("topright", legend = levels(data.merge[, "CLASS"]), text.col = levels(as.factor(as.numeric(data.merge[, "CLASS"]))))
text(labels = data.merge[, "Pathway"], col = as.numeric(data.merge[, "CLASS"]), srt = 45, xpd = T, adj = 1, cex = 0.7,
		x = 3 * (1:nrow(data.merge)) - 1,
		y = -rep(max(data.merge[, c("precent.x", "precent.y")]) / 50,, nrow(data.merge)))

dev.off()
