args <- commandArgs("T")
profile.file <- args[1]
group.file <- args[2]
pdf.file <- args[3]

# profile.file = "ardb.profile"
# group.file <- "group.txt"

source('/home/liulf/real_metagenome_test/tool/labels2colors.R')
library("beeswarm")

diamondCI <- function(x, w, y1, y2, y3, y4, y5, col,...){
  hw <- w/2
  a <- c(x-hw,x,x+hw,x);
  b <- c(y3,y4,y3,y2);
  polygon(a,b,border=col,...)
  segments(x-hw, y3, x+hw, y3,col =col, ...)  # horizontal bar
  segments(x-hw, y3, x, y4,col =col, ...) # left upper diag
  segments(x, y4, x+hw, y3,col =col, ...) # right upper diag
  segments(x-hw, y3, x, y2,col =col, ...) # left lower diag
  segments(x, y2, x+hw, y3,col =col, ...) # right lwoer diag
  arrows(x, y4, x, y5, angle = 90,col=col, ...)
  arrows(x, y2, x, y1, angle = 90,col=col, ...)
}


profile.data <- read.table(profile.file, check.names = F, header = T,row.names = 1,quote="",sep="\t")
group <- read.table(group.file, check.names = F, row.names = 1)
profile.data <- profile.data[,rownames(group)]

color_list = group2corlor(group)
sample_colors = color_list[[1]]
group_colors  = color_list[[2]]
group_names = color_list[[3]]
group = color_list[[4]]
sample.list <- group[,1]

sum_vector = apply(profile.data, 2, mean)
mat = as.matrix(cbind(sum_vector,as.character(group$V2)))
factors = attributes(as.factor(mat[,2]))$levels

box <- boxplot(as.numeric(mat[,1]) ~ as.character(mat[,2]))
pdf(pdf.file, width = 8, height = 6)
beeswarm(as.numeric(mat[,1]) ~ as.character(mat[,2]),labels="",spacing=1.5,xlim=c(0.5,2*length(factors)+0.5),
	        ylim=range(as.numeric(mat[,1]))*c(1,1.1),at=(1:length(factors))*2-1,pch=21,
			col=group_colors,ylab="Relative abundance (%)",xlab="")
#mtext(text = c("Health","Ankylosing\nsporidylitis"),side=1,at=c(1.5,3.5),padj=1)
mtext(text =group_names,side=1,at=c(1.5,3.5),padj=1)


patients = (as.numeric(mat[,1]))[sample.list==names(table(sample.list))[1]]
healths = (as.numeric(mat[,1]))[sample.list==names(table(sample.list))[2]]
pvalue = wilcox.test(patients, healths)$p.value

legend("topright", legend = paste("wilcoxon test:\np.value =", signif(pvalue, digit = 3)), bty = "n")
stat = box$stats
for ( i in 1:ncol(stat)){
  diamondCI(i * 2, 0.8, stat[1, i], stat[2, i], stat[3, i], stat[4, i], stat[5, i], col = group_colors[i], lwd = 1.5)
}
dev.off()