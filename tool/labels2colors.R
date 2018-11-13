cols_brewer = c('#00447E','#F34800','#64A10E','#930026','#464E04','#049a0b','#4E0C66','#D00000','#FF6C00','#FF00FF','#c7475b','#00F5FF','#BDA500','#A5CFED','#f0301c','#2B8BC3','#FDA100','#54adf5','#CDD7E2','#9295C1',"#FF0000FF", "#FF9900FF", "#CCFF00FF", "#33FF00FF" ,"#00FF66FF", "#00FFFFFF" ,"#0066FFFF" ,"#3300FFFF","#CC00FFFF","#FF0099FF")
library(RColorBrewer)
pathcolors <- brewer.pal(6,"Dark2")
names(pathcolors)=c("Metabolism","Genetic Information Processing","Environmental Information Processing","Cellular Processes","Organismal Systems","Human Diseases")
labels2colors <- function (labels, colorSeq = NULL, naColor = "grey", 
  commonColorCode = TRUE) 
{
	if (is.null(colorSeq)){
		if(length(labels) > 20){
			times = ceiling(length(labels) / 20)
			cols_brewer = rep(cols_brewer,times)
		}
		colorSeq = cols_brewer
	}
	if (is.numeric(labels)) {
		labels = as.factor(as.character(labels))
	}
	if (commonColorCode) {
		factors = factor(c(as.matrix(as.data.frame(labels))))
		nLabels = as.numeric(factors)
		dim(nLabels) = dim(labels)
	} else {
		labels = as.matrix(as.data.frame(labels))
		factors = list()
		for (c in 1:ncol(labels)) factors[[c]] = factor(labels[, 
		c])
		nLabels = sapply(factors, as.numeric)
	}
	if (max(nLabels, na.rm = TRUE) > length(colorSeq)) {
		nRepeats = as.integer((max(labels) - 1)/length(colorSeq)) + 
			1
		warning(paste("labels2colors: Number of labels exceeds number of avilable colors.", 
			"Some colors will be repeated", nRepeats, "times."))
		extColorSeq = colorSeq
		for (rep in 1:nRepeats) extColorSeq = c(extColorSeq, 
			paste(colorSeq, ".", rep, sep = ""))
	} else {
		nRepeats = 1
		extColorSeq = colorSeq
	}
	colors = rep("grey", length(nLabels))
	fin = !is.na(nLabels)
	colors[!fin] = naColor
	finLabels = nLabels[fin]
	colors[fin][finLabels != 0] = extColorSeq[finLabels[finLabels != 0]]
	if (!is.null(dim(labels))) 
	dim(colors) = dim(labels)
	colors
}
group2corlor <- function (group, sort_names = NULL) {
	if(!is.null(sort_names)){
		group = as.data.frame(group[sort_names,1])
		rownames(group) = sort_names
		colnames(group) = 'Group'
	}
	sample_name = row.names(group);
	group_name = group[,1]
	sample_colors = labels2colors(group_name);
	group_colors = unique(sample_colors);
	group_names = as.character(unique(group_name))
	list(sample_colors,group_colors,group_names,group)
}
