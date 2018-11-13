library(pROC)
library(MASS)
library(RColorBrewer)
args <- commandArgs("T")
if(length(args) != 4){
  cat("Usage: Rscript",args[0],"datafile diffKOfile samplegroupfile pdffile")
  quit()
}

data.file <- read.table(args[1],sep="\t",header=T,row.names=1,check.names=F,quote="")
diffKO.file <- read.table(args[2],sep="\t",header=F)
samplegroup.file <- read.table(args[3],sep="\t",header=F)
data = data.file[as.character(diffKO.file[,1]),]
data <- data[,as.character(samplegroup.file[,1])]
data <- as.data.frame(t(data))
lab <- samplegroup.file[,2]

model <- lda(lab ~ ., data = data,tol=1e-30)
result.lda <- predict(model,data)

pdf(args[4])
plot.roc(lab, result.lda$x[,1], of="se",ci=TRUE,ci.col=brewer.pal(6,"Dark2"),ci.type="s",print.auc=T,print.auc.col="blue",col="red")
tt <- as.numeric(roc(lab, result.lda$x[,1],ci=T)$ci)
text(0.5,0.55,paste0("95% CI:",round(tt[1],2),"-",round(tt[3],2)),col = "blue",adj=0)
dev.off()

