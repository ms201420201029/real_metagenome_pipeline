source("{{ tool_default_dir }}/labels2colors.R")
profile.table = "{{ profile_table }}"
group.file = "{{ group_file }}"
pdf.file = "{{ pdf_file }}"
library(cluster)
library(fpc)
library(ade4)
profile <- read.table(profile.table, header = T, check.names= F,row.names=1,quote="",sep="\t")
group <- read.table(group.file, head = F, check.names = F, row.names = 1, col.names = c("", "group.name"))

profile = profile[,rownames(group)]
color_list = group2corlor(group)
sample_colors=color_list[[1]]
group_colors= color_list[[2]]
group_names = color_list[[3]]
group = color_list[[4]]


profile.pca = dudi.pca(t(profile), scannf = F, nf = 2)
pdf(pdf.file);
#layout(matrix(c(1,1,1,3,
#		1,1,1,3,
#		1,1,1,3,
#		2,2,2,0), byrow = T, ncol = 4));
#col.sample <- c("lightblue", "salmon", "orange", "lightpink", "seagreen", "orchid", "royalblue")
par(mar = c(5, 5, 5, 5));
pca.eig <- signif(profile.pca$eig / sum(profile.pca$eig), digits = 4);

if (ncol(profile) <= 10) {
	pca.cex <- 4
}else if (ncol(profile) <= 30){
	pca.cex <- 2
}else {
	pca.cex <- 1
}

#plot(profile.pca$li, pch = 20, col = col.sample[as.numeric(group[, 1])], cex = pca.cex,
#     main = paste("PCA"),
#     xlab = paste("PCA1: ", pca.eig[1] * 100, "%", sep = ""),
#     ylab = paste("PCA2: ", pca.eig[2] * 100, "%", sep = ""))

if (ncol(profile) <= 10) {
  for (i in 1 : ncol(profile)){
    text(x = profile.pca$li[i, 1], y = profile.pca$li[i, 2], labels = colnames(profile)[i], xpd = T)
  }
}

# Kmeans clustre analysis
clus <- kmeans(profile.pca$li, centers=length(unique(group[,1])),iter.max = 500)
clusplot(-profile.pca$li, clus$cluster, #shade=TRUE,
		 col.p = sample_colors,
         labels=0, lines=0,xlab = paste0("PC1(",round(profile.pca$eig[1]/sum(profile.pca$eig)*100,2),"%)"),
         ylab = paste0("PC2(",round(profile.pca$eig[2]/sum(profile.pca$eig)*100,2),"%)"),
         main = "PCA analysis",sub="")
legend("topleft",legend=group_names,col=group_colors,pch=15)
#par(mar = c(3, 5, 2, 5));
#boxplot(profile.pca$li[,1] ~ group[, 1], pch = 20, col = group_colors, notch = F, horizontal = T);
#par(mar = c(5, 2, 5, 3));
#boxplot(profile.pca$li[,2] ~ group[, 1], pch = 20, col = group_colors, notch = F);
dev.off();
