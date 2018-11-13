args <- commandArgs("T")
profile <- read.table(args[1], head = T, check.names= F)
group <- read.table(args[2], head = F, check.names = F, row.names = 1, col.names = c("", "group.name"))
library(ade4)
profile.pca = dudi.pca(t(profile), scannf = F, nf = 2)
pdf(args[3]);
layout(matrix(c(1,1,1,3,
		1,1,1,3,
		1,1,1,3,
		2,2,2,0), byrow = T, ncol = 4));
#col.sample <- topo.colors(length(attr(sample.list,"levels")));
col.sample <- c("orange", "royalblue", "seagreen", "orchid", "lightpink")
par(mar = c(5, 5, 5, 5));
pca.eig <- signif(profile.pca$eig / sum(profile.pca$eig), digits = 4);

if (ncol(profile) <= 10) {
	pca.cex <- 4
}else if (ncol(profile) <= 30){
	pca.cex <- 2
}else {
	pca.cex <- 1
}

plot(profile.pca$li, pch = 20, col = col.sample[as.numeric(group[, 1])], cex = pca.cex,
     main = paste("PCA"),
     xlab = paste("PCA1: ", pca.eig[1] * 100, "%", sep = ""),
     ylab = paste("PCA2: ", pca.eig[2] * 100, "%", sep = ""))

if (ncol(profile) <= 10) {
  for (i in 1 : ncol(profile)){
    text(x = profile.pca$li[i, 1], y = profile.pca$li[i, 2], labels = colnames(profile)[i], xpd = T)
  }
}
par(mar = c(3, 5, 2, 5));
boxplot(profile.pca$li[,1] ~ group[, 1], pch = 20, col = col.sample, notch = F, horizontal = T);
par(mar = c(5, 2, 5, 3));
boxplot(profile.pca$li[,2] ~ group[, 1], pch = 20, col = col.sample, notch = F);
dev.off();
