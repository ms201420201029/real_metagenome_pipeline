args <- commandArgs("T")
library(qvalue)
table.file = args[1]
pdf.file = args[2]
date = read.table(table.file,header=T,sep="\t",check.names=F,quote="",row.names=1)
p.value = date[,ncol(date)-2]
pi0 <- tryCatch(qvalue(na.omit(p.value))$pi0, warning = function(w) {-1});
pdf(pdf.file);
hist.p = hist(p.value, probability = T, breaks = 50, main = "histogram of p values", xlab = "p values");
if (pi0 > 0){
        cex <- max(hist.p$density);
        axis(4, at = (0:5) / 5 * cex, labels = (0:5) / 5);
        power.p <- c(0, cumsum(hist.p$density - pi0) / 50 / (1 - pi0));
        fdr.p   <- c(0, pi0 * (1:50) / cumsum(hist.p$density));
        abline(h = pi0, lty = 2);
        #lines(x = (0:50) / 50, y = power.p * cex, type = "o", pch = 4, cex = 0.5, col = 2, lwd = 1);
        #lines(x = (0:50) / 50, y = fdr.p   * cex, type = "o", pch = 4, cex = 0.5, col = 4, lwd = 1);
        legend(x = 1, y = pi0, legend = "Null Hypothesis", xjust = 1, yjust = 0, bty = "n");
        #legend(x = 1, y = max(fdr.p * cex), legend = c("estimate power", "estimate fdr"), col = c(2,4), xjust = 1, yjust = 0, pch = 4, lwd = 1, pt.cex = 0.5, bty = "n");
}
dev.off();
