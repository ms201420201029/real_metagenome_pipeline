#group分组
groupfile = "{{ groupfile }}"
#物种丰度
tabledata = "{{ taxfile }}"
#挑选的水平
level = "{{ level }}"
#kegg
genefile = "{{ keggfile }}"
#pdf输出
pdfout = "{{ pdf_out }}"
#挑选的阈值
cutoff.p <- {{ cutoff_p }}
cutoff.estimate <- {{ cutoff_estimate }}
filter = "{{ filter }}"
source("{{ default_dir }}/alternative/mycorr.R")
source("{{ default_dir }}/tool/labels2colors.R")
library("corrplot")

# need file otu_table_for_lefse2.txt metagenome_predictions.L3.txt group.txt--------
group = read.table(file=groupfile,check.names = F,header = F,row.names = 1,quote = "",sep = "\t",stringsAsFactors = F)
data = read.table(file=tabledata,check.names = F,quote = "",sep = "\t",row.names = 1,header = T,stringsAsFactors = F)
#去除没有level水平的物种
newcolnamefun <- function(levelname){
  newcolname=c()
  rm_index = c()
  colnamestr = strsplit(x = rownames(data),split = "|",fixed = T)
  for(i in 1:length(colnamestr)){
    if(length(colnamestr[[i]][grep(levelname,colnamestr[[i]])])==1){
      newcolname=c(newcolname,colnamestr[[i]][grep(levelname,colnamestr[[i]])])
    }else{
      rm_index <- c(rm_index,i)
    }
  }
  return(list(rm_index,newcolname))
}
rm_index_fun <- function(level) {
  switch (level,
          "species" = newcolnamefun("s__"),
          "genus" = newcolnamefun("g__"),
          "family" = newcolnamefun("f__"),
          "order" =newcolnamefun("o__"),
          "class"=newcolnamefun("c__"),
          "phylum"=newcolnamefun("p__"),
          "kingdom"=newcolnamefun("k__")
  )
}
temp_1 <- rm_index_fun(level=level)
temp_2 <- temp_1[[1]]
temp_3 <- temp_1[[2]]
data=data[-temp_2,]
rownames(data) <- temp_3
data = data[,rownames(group)]


genefunction = read.table(file = genefile,check.names = F,quote = "",sep = "\t",row.names = 1,header = T)
genefunction = genefunction[,rownames(group)]

color_list = group2corlor(group)
sample_colors=color_list[[1]]
group_colors= color_list[[2]]
group_names = color_list[[3]]
group = color_list[[4]]
group_index = tapply(1:nrow(group),group[,1],c)

usefuldata = data
usefulgene = genefunction
#处理缺失值
for(k in 1:length(group_index)){
  if(length(which(apply(usefuldata[,group_index[[k]]],1,var)==0))>0){
    print("remove 0")
    usefuldata = usefuldata[-which(apply(usefuldata[,group_index[[k]]],1,var)==0),]
  }
  if(length(which(apply(usefulgene[,group_index[[k]]],1,var)==0))>0){
    print("kegg remove 0")
    usefulgene = usefulgene[-which(apply(usefulgene[,group_index[[k]]],1,var)==0),]
  }
}

#  --------------------细菌在哪组中富集----------------------------------------------------
names(group_colors) = group_names
bacterial.color <- group_colors[apply(usefuldata,1,function(x) group_names[order(tapply(x,group[,1],mean),decreasing = T)[1]])]
usefuldata <- usefuldata[order(bacterial.color),]
bacterial.color <- group_colors[apply(usefuldata,1,function(x) group_names[order(tapply(x,group[,1],mean),decreasing = T)[1]])]

for(k in 1:length(group_index)){

  dataframe.p=c()
  dataframe.estimate=c()
  for(i in 1:nrow(usefuldata)){
    p.value=c()
    cor.estimate=c()
    for(j in 1:nrow(usefulgene)){
      cordatatemp = cor.test(as.numeric(usefuldata[i,group_index[[k]]]),as.numeric(usefulgene[j,group_index[[k]]]),method="kendall")
      p.value=rbind(p.value,cordatatemp$p.value)
      cor.estimate=rbind(cor.estimate,cordatatemp$estimate)
    }
    #          print(p.value)
    dataframe.p=cbind(dataframe.p,p.value)
    dataframe.estimate=cbind(dataframe.estimate,cor.estimate)
  }
  rownames(dataframe.p)=rownames(usefulgene)
  rownames(dataframe.estimate)=rownames(usefulgene)
  colnames(dataframe.p)=rownames(usefuldata)
  colnames(dataframe.estimate) =rownames(usefuldata)
  #保存数据
  write.table(dataframe.estimate,file = paste("dataframe_estimate",k,".txt",sep = ""),sep="\t",quote = F)
  write.table(dataframe.p,file = paste("dataframe_p",k,".txt",sep=""),sep="\t",quote=F)



  # 画图 ----------------------------------------------------------------------
  if(k==1){
    if(filter=="est"){
      temp <- which(apply(dataframe.estimate,1,max)>cutoff.estimate)
      if(length(temp)==0){
        stop("cutoff.estimate 太大了")
      }
      dataframe.estimate=dataframe.estimate[temp,]
      dataframe.p =dataframe.p[temp,]
    }else{
      temp <- which(apply(dataframe.estimate,1,max)<cutoff.p)
      if(length(temp)==0){
        stop("p value 太小了")
      }
      dataframe.estimate=dataframe.estimate[temp,]
      dataframe.p =dataframe.p[temp,]

    }
  }else{
    dataframe.estimate=dataframe.estimate[temp,]
    dataframe.p =dataframe.p[temp,]
  }

  rownamestr <- tryCatch(strsplit(rownames(dataframe.estimate),split = ":",fixed = T), error = function(e) {NA})
  if(!is.na(rownamestr)){
    newcolname=c()
    for(i in 1:length(rownamestr)){
      newcolname=c(newcolname,rownamestr[[i]][length(rownamestr[[i]])])
    }
    rownames(dataframe.estimate)=newcolname
  }

  rows <- rownames(dataframe.estimate)
  names(rows) <- paste0("P",1:nrow(dataframe.estimate))
  rownames(dataframe.estimate)=paste0("P",1:nrow(dataframe.estimate))
  rownames(dataframe.p)=paste0("P",1:nrow(dataframe.estimate))
  # 修改菌的名称 ------------------------------------------------------------------
  # colnames(dataframe.estimate) <- sapply(strsplit(colnames(dataframe.estimate),"__"),function(x) x[2])

  if(k==1){
    pdf(pdfout,height = 0.9*length(temp_3),width = 15)
    layout(mat = t(t(1:(length(group_index)+1))),heights  = c(rep(0.5,length(group_index)),0.3))
    par(mar = c(0,0,0,0))
    tt <- mycorr(t(as.matrix(dataframe.estimate)),is.corr = TRUE,p.mat=t(as.matrix(dataframe.p)),sig.level = 0.05,insig="pch",
           pch = 0, pch.col = "#BB4444", pch.cex =4,mar = c(2,1,0,1),tl.pos="n",
           tl.cex = 1.3,tl.col="black",
           cl.pos="n",
           col = colorRampPalette(brewer.pal(11,"PRGn"))(200),title="")
    segments(x0=-7,y0=.5,x1=-7,y1=9.5,lwd = 3)
    text(x=-8,y=5.5,labels = names(group_index)[k],cex=3,font=2,col="red")


    text(y = 1:length(colnames(dataframe.estimate)),x=0,labels = rev(colnames(dataframe.estimate)),xpd=T,adj=1,col = rev(bacterial.color))
    segments(x0=0,y0=.5,x1=3,y1=0.5,lwd=3)
    # text(x=2,y=0.2,labels = "tttt")

  }else{
    mycorr(t(as.matrix(dataframe.estimate)),is.corr = TRUE,p.mat=t(as.matrix(dataframe.p)),sig.level = 0.05,insig="pch",
           pch = 0, pch.col = "#BB4444", pch.cex=4,mar = c(2,1,0,1),tl.pos="n",
           cl.pos="n",col = colorRampPalette(brewer.pal(11,"PRGn"))(200),title = "")
    text(y = 1:length(colnames(dataframe.estimate)),x=0,labels = rev(colnames(dataframe.estimate)),xpd=T,adj=1,cex=1.3,col = rev(bacterial.color))
    segments(x0=-7,y0=0.5,x1=-7,y1=9.5,lwd = 3)
    text(x=-8,y=5.5,labels = names(group_index)[k],col = "green",cex=3,font=2)
    text(x = 1:length(rownames(dataframe.estimate)),y=0,
         labels = rownames(dataframe.estimate),xpd=T,adj=0)
    plot(0,type="n",xlab="",ylab = "",xaxt="n",yaxt="n",bty="n",xlim = c(0,10),ylim = c(0,10))
    mycolorlegend(colbar = colorRampPalette(brewer.pal(11,"PRGn"))(200), labels = round(seq(-1, 1, length = 11),2),  ratio.colbar = 0.8,xlim =c(0,9), ylim =c(0,1),
                  vertical = T, align = "c")
    legend("center",legend = paste0(names(rows),":",rows),ncol=2,cex=0.9,text.font = 2)
    legend("left",legend = group_names,pch = 15,cex=2,col = group_colors)
    if(filter=="est"){
      legend(x=1,y=9,legend = paste0("estimate>",cutoff.estimate),pch=0,col="#BB4444",cex=2,pt.lwd=4,pt.cex = 4)
    }else{
      legend(x=1,y=9,legend = paste0("p<",cutoff.p),pch=0,col="#BB4444",cex=2,pt.lwd=4,pt.cex = 4)
    }
  }
}
dev.off()