# 把时间设置成factor ------------------------------------------------------------
library(ggplot2)
library(randomForest)
data <- read.table("../../data/wuchuny//otu_table_L6.filter.txt",check.names = F,quote = "",sep = "\t",row.names = 1,header = T)
groupfile <- read.table("",check.names=F,quote="",sep="\t",row.names=1,header=F)
rownames(data) <- gsub("/","",gsub("_","",gsub(" ","",sapply(strsplit(rownames(data),split = "g__"),function(x) x[2]))))
tempages <- as.numeric(sapply(sapply(strsplit(colnames(data),split="-"),function(x) strsplit(x[1],split="A|B|C")),function(x) x[2]))
for(i in 5:8){
  tempages[tempages==i]=5
}

data  <- as.data.frame(t(data))
data[,"age"] <- as.factor(tempages)
dataA  <- data[grep("FA",rownames(data)),]
dataB <- data[grep("FB",rownames(data)),]
dataC <- data[grep("FC",rownames(data)),]


fit.forest <- randomForest(age~.,data=dataC,importance=T,proximity=TRUE,ntree=1000)
write.table(round(importance(fit.forest,type = 2),3),file = "../../data/wuchuny/importance2.txt",quote=F)
# agesA <- dataA[,"age"]
# agesB <- dataB[,"age"]
# agesC <- dataC[,"age"]
impv <- rownames(importance(fit.forest,type = 1))[order(importance(fit.forest,type = 2),decreasing = T)]
dataA <- dataA[,c(impv,"age")]
dataB <- dataB[,c(impv,"age")]
dataC <- dataC[,c(impv,"age")]


pdf("../../data/wuchuny/importance2.pdf",10,15)
varImpPlot(fit.forest)
dev.off()
result <- rfcv(dataC[,-ncol(dataC)],dataC[,ncol(dataC)],cv.fold=10,step = 0.9)

pdf("../../data/wuchuny/10-flod2.pdf")
with(result, plot(n.var, error.cv, log="x", type="o", lwd=2))
dev.off()

fit.forest.t  <- randomForest(age~.,data=dataC[,c(impv[1:23],"age")],importance=T,proximity=TRUE,ntree=1500,mtry=2)
fit.preA <- predict(fit.forest.t,dataA[,impv[1:23]])
fit.preB <- predict(fit.forest.t,dataB[,impv[1:23]])
fit.preC <- predict(fit.forest.t,dataC[,impv[1:23]])
library(ggplot2)
agesA <- as.numeric(sapply(sapply(strsplit(names(fit.preA),split="-"),function(x) strsplit(x[1],split="A|B|C")),function(x) x[2]))
agesB <- as.numeric(sapply(sapply(strsplit(names(fit.preB),split="-"),function(x) strsplit(x[1],split="A|B|C")),function(x) x[2]))
agesC <- as.numeric(sapply(sapply(strsplit(names(fit.preC),split="-"),function(x) strsplit(x[1],split="A|B|C")),function(x) x[2]))
dataAA <- data.frame(as.numeric(as.character(fit.preA)),agesA,rep("A",length(agesA)))
dataBB <- data.frame(as.numeric(as.character(fit.preB)),agesB,rep("B",length(agesB)))
dataCC <- data.frame(as.numeric(as.character(fit.preC)),agesC,rep("C",length(agesC)))
colnames(dataAA)=c("pre","age","group")
colnames(dataBB)=c("pre","age","group")
colnames(dataCC)=c("pre","age","group")
pdf("../../data/wuchuny/randomForest2-1.pdf",20,15)
layout(c(1,2,3))
ggplot(dataAA,aes(x=age,y=pre,colors=group))+geom_point()+geom_smooth()
ggplot(dataBB,aes(x=age,y=pre,colors=group))+geom_point()+geom_smooth()
ggplot(dataCC,aes(x=age,y=pre,colors=group))+geom_point()+geom_smooth()
dev.off()

dataall <- rbind(dataAA,dataCC,dataBB)

pdf("../../data/wuchuny/randomForest2-2.pdf",20,15)
ggplot(data=dataall,aes(x=age,y=pre,col=group))+geom_point()+geom_smooth()
dev.off()
write.table(dataall,file = "../../data/wuchuny/randomForest2-2.txt",quote=F)
dataAA1 <- data.frame(as.numeric(as.character(fit.preA)),as.numeric(as.character(dataA[,"age"])),rep("A",length(agesA)))
dataBB1 <- data.frame(as.numeric(as.character(fit.preB)),as.numeric(as.character(dataB[,"age"])),rep("B",length(agesB)))
dataCC1 <- data.frame(as.numeric(as.character(fit.preC)),as.numeric(as.character(dataC[,"age"])),rep("C",length(agesC)))
colnames(dataAA1)=c("pre","age","group")
colnames(dataBB1)=c("pre","age","group")
colnames(dataCC1)=c("pre","age","group")
dataall2=rbind(dataAA1,dataBB1,dataCC1)
write.table(dataall2,file = "../../data/wuchuny/randomForest2-1.txt",quote=F)
pdf("../../data/wuchuny/randomForest2-1.pdf",20,15)
ggplot(data=dataall2,aes(x=age,y=pre,col=group))+geom_point()+geom_smooth()
dev.off()
