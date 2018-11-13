WilcoxTest <- function(abun, group.class){
        test <- wilcox.test(abun ~ group.class, pair = F, alternative = "two.sided");
	if (test$statistic < table(group.class)[1] * table(group.class)[2] / 2){
		enrich <- names(table(group.class))[2]
	}else {
		enrich <- names(table(group.class))[1]
	}
        c(test$p.value, enrich);
}

arg          <- commandArgs("T");
group.file   <- arg[1];
profile.file <- arg[2];
group.class  <- read.table(group.file,   header = F, check.names = F, row.names = 1);
profile.data <- read.table(profile.file, header = T, check.names = F)[,rownames(group.class)];
group.class  <- group.class[,1];
p.enrich     <- apply(profile.data, 1, WilcoxTest, group.class = group.class);
p.value      <- as.numeric(p.enrich[1,]);
enrich       <- p.enrich[2,];
q.value      <- p.adjust(p.value, method = "fdr");
q.p.enrich   <- cbind(p.value, q.value, enrich);
write.table(q.p.enrich, paste(profile.file, ".p", sep = ""), col.names = F, sep = "\t", quote = F);
library(qvalue);
pi0 <- tryCatch(qvalue(na.omit(p.value))$pi0, warning = function(w) {-1});
pdf(paste(profile.file, ".p.pdf", sep = ""));
hist.p = hist(p.value, probability = T, breaks = 50, main = "histogram of p values", xlab = "p values");
if (pi0 > 0){
	cex <- max(hist.p$density);
	axis(4, at = (0:5) / 5 * cex, labels = (0:5) / 5);
	power.p <- c(0, cumsum(hist.p$density - pi0) / 50 / (1 - pi0));
	fdr.p   <- c(0, pi0 * (1:50) / cumsum(hist.p$density));
	abline(h = pi0, lty = 2);
	lines(x = (0:50) / 50, y = power.p * cex, type = "o", pch = 4, cex = 0.5, col = 2, lwd = 1);
	lines(x = (0:50) / 50, y = fdr.p   * cex, type = "o", pch = 4, cex = 0.5, col = 4, lwd = 1);
	legend(x = 1, y = pi0, legend = "Null Hypothesis", xjust = 1, yjust = 0, bty = "n");
	legend(x = 1, y = max(fdr.p * cex), legend = c("estimate power", "estimate fdr"), col = c(2,4), xjust = 1, yjust = 0, pch = 4, lwd = 1, pt.cex = 0.5, bty = "n");
}
dev.off();
