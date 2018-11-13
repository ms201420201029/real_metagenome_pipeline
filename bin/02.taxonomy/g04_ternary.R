args <- commandArgs("T")
profile <- read.table(args[1], head = T, check.names = F,quote="",sep="\t",row.names=1);
group <- read.table(args[2], head = F, check.names = F, row.names = 1,quote="",sep="\t")
colors = c('#00447E','#F34800','#64A10E','#930026','#464E04','#049a0b','#4E0C66','#D00000','#FF6C00','#FF00FF','#c7475b','#00F5FF','#BDA500','#A5CFED','#f0301c','#2B8BC3','#FDA100','#54adf5','#CDD7E2','#9295C1',"#FF0000FF", "#FF9900FF", "#CCFF00FF", "#33FF00FF" ,"#00FF66FF", "#00FFFFFF" ,"#0066FFFF" ,"#3300FFFF","#CC00FFFF","#FF0099FF")
#colors <- c("lightblue", "salmon", "orange", "lightpink", "seagreen", "orchid", "royalblue")
#pch <- substr(levels(Positions), 1, 1)
rowsum <- apply(profile, 1, sum)
profile <- profile[rev(order(rowsum))[1:2], ]
other <- 1 - apply(profile, 2, sum)
profile <- rbind(profile, other)
rownames(profile)[3] = "Other"
if (ncol(profile) < 10) {
  cex = 3
}else if (ncol(profile) < 20) {
  cex = 2
}else {
  cex = 1
}
pdf(args[3], height = 7, width = 10)
library(vcd)
ternaryplot(
  t(profile),
  pch = 20,
  col = colors[as.numeric(group[, 1])],
  main = paste("Two Main", args[4], "in Samples"),
  labels = "outside",
  grid = 'dashed',
  cex = cex
)
pch = 20
grid_legend(0.8, 0.7, pch, colors, levels(group[, 1]),  title = "Samples")
dev.off()
