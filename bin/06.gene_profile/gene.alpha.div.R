args <- commandArgs("T")

data <- read.table(args[1], head = T, check.names = F, sep = "\t", comment.char = "")
group <- read.table(args[2], head = F, row.names = 1, check.names = F)
pdf(args[3])
layout(matrix(c(1,2),1,2))

col.sample <- c("orange", "royalblue", "seagreen", "orchid")
boxplot(0, type = "n", xaxt = "n", ylab = "Shannon-Wiener Diversity Index", xlim = c(0.5, 0.5 + length(levels(group[, 1]))), ylim = range(data[, 3]))
for (i in 1:length(levels(group[, 1]))){
  group.name <- which(group[, 1] == levels(group[, 1])[i])
  boxplot(data[group.name, 3],at=i,pch=20,col=col.sample[i],xaxt="n",add=TRUE)
}
axis(1, labels = levels(group[, 1]), at = 1:length(levels(group[, 1])), padj=1)
#mean_HD=mean(shannon_HD)
#mean_AS=mean(shannon_AS)
#points(x=1,y=mean_HD,pch=3,col="red")
#points(x=2,y=mean_AS,pch=3,col="red")
#mtext("Diversity of downsize data",at=3,line=1)
col.sample <- c("orange", "royalblue", "seagreen", "orchid")
boxplot(0, type = "n", xaxt = "n", ylab = "Simpson Diversity Index", xlim = c(0.5, 0.5 + length(levels(group[, 1]))), ylim = range(data[, 4]))
for (i in 1:length(levels(group[, 1]))){
  group.name <- which(group[, 1] == levels(group[, 1])[i])
  boxplot(data[group.name, 4],at=i,pch=20,col=col.sample[i],xaxt="n",add=TRUE)
}
axis(1, labels = levels(group[, 1]), at = 1:length(levels(group[, 1])), padj=1)
#boxplot(simpson_HD,notch=TRUE,at=1,pch=20,col="bisque",xaxt="n",ylab="Simpson Diversity Index",xlim=c(0.5,2.5))
#boxplot(simpson_AS,notch=TRUE,at=2,pch=20,col="lightblue",xaxt="n",add=TRUE)
#axis(1,labels=c("Healthy","Ankylosing\nspondylitis"),at=c(1,2),padj=1)
#mean_HD=mean(simpson_HD)
#mean_AS=mean(simpson_AS)
#points(x=1,y=mean_HD,pch=3,col="red")
#points(x=2,y=mean_AS,pch=3,col="red")
dev.off()
