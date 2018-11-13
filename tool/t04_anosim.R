source("{{ tool_default_dir }}/labels2colors.R")
profile.table <- "{{ profile_table }}"
group.file <- "{{ group_file }}"
pdf.file = "{{ pdf_file }}"
txt.file = "{{ txt_file }}"
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
Anosim <- function(dist.data, sample.list, method){
	library(vegan);
	anosim.data <- anosim(dist.data, sample.list, permutations = 9999);
	class.dist  <- anosim.data$class.vec;
	names.class <- c(attr(class.dist, "levels")[which(attr(class.dist, "levels") != "Between")], "Between");
#	cols.class  <- c(topo.colors(length(names.class) - 1), "orange");
	if (length(names.class) > 20) {
	  cols.class <- topo.colors(length(attr(sample.list,"levels")))
	}else {
	   cols.class <- cols_brewer
	}
	class.dist  <- factor(class.dist, levels = names.class);
	pdf(pdf.file)
	boxplot(dist.data ~ class.dist, pch = 20, col = cols.class,
		ylim = c(min(dist.data), max(dist.data) * 1.1),
		main = paste("Distance of", method, "within and between groups"));
	text(x = length(names.class), y = max(dist.data) * 1.05, adj = 1,
	     labels = paste("Anosim test:", "p=",round(anosim.data$signif,3)," R=",round(anosim.data$statistic,3)));
	dev.off();
	#anosim.info <- c(anosim.data$statistic, anosim.data$signif)
    #cat(anosim.data$statistic)
	#write(anosim.info, file = txt.file)
	
	
	t = as.data.frame(c(method, anosim.data$statistic, anosim.data$signif, 9999))
	t = t(t)
	colnames(t) = c('Method name', 'R statistic', 'P-value', 'Permutation number')
	write.table(t, file=txt.file, quote=F, sep='\t', row.names=F)
}




profile.data <- read.table(profile.table, check.names = F, header = T,row.names = 1,quote="",sep="\t")
sample.group <- read.table(group.file,   check.names = F, row.names = 1)
profile.data <- profile.data[,rownames(sample.group)]
dist.data    <- Dist(t(profile.data), method = method)
sample.group = sample.group[,1]
Anosim(dist.data, sample.group, method = method)
