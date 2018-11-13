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

Pcoa <- function(dist.data, sample.list, method){
	library(ade4);
	pcoa <- dudi.pco(dist.data, scannf = F, nf = 2);
	pdf(pdf.file)
	if (length(attr(sample.list,"levels")) > 20) {
	  col.sample <- topo.colors(length(attr(sample.list,"levels")));
	}else {
	  col.sample <- cols_brewer
	}
	par(mar = c(5, 5, 5, 5));
	pcoa.eig <- signif(pcoa$eig, digits = 3);
	if (length(sample.list) <= 10) {
	  pcoa.cex <- 4
	}else if (length(sample.list) <= 30){
	  pcoa.cex <- 2
	}else {
	  pcoa.cex <- 1
	}
	plot(pcoa$li, pch = c(1:20)[sample.list[,2]], col = col.sample[sample.list[,1]],
	     main = paste("PCoA by distance of", method, "between samples"),
	     xlab = paste("PCoA1: ", signif(pcoa.eig[1]/sum(pcoa$eig) * 100,digits=3), "%", sep = ""),
	     ylab = paste("PCoA2: ", signif(pcoa.eig[2]/sum(pcoa$eig) * 100,digits=3), "%", sep = ""),
	     cex = pcoa.cex)
	if (length(sample.list) <= 10) {
	  for (i in 1 : length(sample.list)){
	    text(x = pcoa$li[i, 1], y = pcoa$li[i, 2], labels = labels(dist.data)[i], xpd = T)
	  }
	}
	dev.off();
}


profile.data <- read.table(profile.table, check.names = F, header = T,row.names = 1,quote="",sep="\t")
sample.group <- read.table(group.file,   check.names = F, row.names = 1)
profile.data <- profile.data[,rownames(sample.group)]
dist.data    <- Dist(t(profile.data), method = method)
Pcoa(dist.data, sample.group, method = method)
