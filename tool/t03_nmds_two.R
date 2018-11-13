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
	plot(nmds$points, pch = c(1:20)[sample.list[,2]], col = col.sample[sample.list[,1]],
	     main = paste("NMDS by distance of", method, "between samples"),
	     xlab = "NMDS1", ylab = "NMDS2",
	     cex = nmds.cex)
	if (length(sample.list) <= 10) {
	  for (i in 1 : length(sample.list)){
	    text(x = nmds$points[i, 1], y = nmds$points[i, 2], labels = labels(dist.data)[i], xpd = T)
	  }
	}
	dev.off();
}


profile.data <- read.table(profile.table, check.names = F, header = T,row.names = 1,quote="",sep="\t")
sample.group <- read.table(group.file,   check.names = F, row.names = 1)
profile.data <- profile.data[,rownames(sample.group)]
dist.data    <- Dist(t(profile.data), method = method)
Nmds(  dist.data, sample.group, method = method)
