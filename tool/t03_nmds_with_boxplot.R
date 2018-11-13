source("{{ tool_default_dir }}/labels2colors.R")
profile.table <- "{{ profile_table }}"
group.file <- "{{ group_file }}"
pdf.file = "{{ pdf_file }}"
method <- "{{ method }}"


Dist <- function(profile.data, method){
	dist.data <- tryCatch(dist(profile.data, method = method), error = function(e) {NA});
	if (class(dist.data) == "dist"){
		dist.data;
	}else {
		library(vegan);
		vegdist(profile.data, method = method);
	}
}
Nmds <- function(dist.data, sample.list, method){
	library(vegan);
	nmds <- metaMDS(dist.data);
	pdf(pdf.file);
	layout(matrix(c(1,1,1,3,
			1,1,1,3,
			1,1,1,3,
			2,2,2,0), byrow = T, ncol = 4));
	if (length(attr(sample.list,"levels")) > 20) {
	    col.sample <- topo.colors(length(attr(sample.list,"levels")))
	}else {
        col.sample <- cols_brewer
	}
	par(mar = c(5, 5, 5, 5));
	if (length(sample.list) <= 10) {
	  nmds.cex <- 4
	}else if (length(sample.list) <= 30){
	  nmds.cex <- 2
	}else {
	  nmds.cex <- 1
	}
	plot(nmds$points, pch = 20, col = col.sample[sample.list],
	     main = paste("NMDS by distance of", method, "between samples"),
	     xlab = "NMDS1", ylab = "NMDS2",
	     cex = nmds.cex)
	if (length(sample.list) <= 10) {
	  for (i in 1 : length(sample.list)){
	    text(x = nmds$points[i, 1], y = nmds$points[i, 2], labels = labels(dist.data)[i], xpd = T)
	  }
	}
	par(mar = c(3, 5, 2, 5));
	boxplot(nmds$points[,1] ~ sample.list, pch = 20, col = col.sample, notch = F, horizontal = T, cex.axis = 0.8);
	par(mar = c(5, 2, 5, 3));
	boxplot(nmds$points[,2] ~ sample.list, pch = 20, col = col.sample, notch = F, cex.axis = 0.8);
	dev.off();
}



profile.data <- read.table(profile.table,check.names = F, header = T,row.names = 1,quote="",sep="\t")
sample.group <- read.table(group.file,check.names = F, row.names = 1)
profile.data <- profile.data[,rownames(sample.group)]
dist.data    <- Dist(t(profile.data), method = method)
sample.group = sample.group[,1]
Nmds(dist.data, sample.group, method = method)
