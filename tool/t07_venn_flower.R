library(VennDiagram)
profile.table <-  "{{ profile_table }}"
group.file <-  "{{ group_file }}"
png.file <-  "{{ png_file }}"
data <-  read.table(profile.table, sep = "\t", header = T, row.names = 1,check.names = F,quote="")
group <-  read.table(group.file,sep="\t",header=F,row.names = 1,check.names=F,quote="")
data <-  data[,rownames(group)]
grouptemp <- tapply(c(1:length(group[,1])),group[,1],c)
data <- t(apply(data,1,function(x) tapply(x,group[,1],sum)))
rnames <- rownames(data)

numberlist <- as.list(as.data.frame(data))

modifylist <-function(list){
  numberlistnames = length(list)
  newlist = list()
  for (i in 1:numberlistnames){
    newlist[[i]] = rnames[which(list[[i]] > 0)]
  }
  names(newlist)=names(list)
  newlist
}

newlist = modifylist(numberlist)
#height width的单位是像素
# newlist is A list of vectors (e.g., integers, chars)
# font控制文字字体的整数(1: 正常,2: 斜体,3: 粗体,4: 粗斜体);
venn.diagram(newlist,  height = 3000, width = 3000,resolution=800,imagetype = "png",units = "px",
             #              main = "main name",main.pos = c(0.5,0.96),main.fontface = 4,main.cex=3,
             label.col = "#3333ff",fontface = "bold",
             cat.col = c("red", "blue","green","#ff9966","yellow")[1:length(newlist)],
             category.names = names(newlist), fill = c("red", "blue","green","#ff9966","yellow")[1:length(newlist)],
             filename = png.file, #sub = "venn Analysis",
             sub.col="red",sub.cex = 2,
             ext.text = TRUE,
             margin=0.01,
             ext.dist = -0.15)



