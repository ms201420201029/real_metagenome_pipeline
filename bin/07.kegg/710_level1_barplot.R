args <- commandArgs("T")
kegg_level1_profile <- args[1]
outfilepdf <- args[2]
title.infor = args[3]
source("/data_center_01/pipeline/real_metagenome/real_metagenome_v1.0.0/tool/labels2colors.R")


data <- read.table(kegg_level1_profile,header=TRUE,row.names=1,sep='\t', check.names=F,quote="")
data <- data[order(apply(data,1,sum),decreasing = T),]
gcolor <- pathcolors[rownames(data)]
if(nrow(data)>19){
   
    data <- data[1:20,]
    gcolor = cols_brewer[1:nrow(data)]
}
if(ncol(data)>0 && ncol(data)<10){
  pdf_width = 6
  mar_r = 6
}else if(ncol(data)>=10 && ncol(data)<16){
  pdf_width = 8
  mar_r =15.5
}else if(ncol(data)>=16 && ncol(data)<21){
  pdf_width = 10
  mar_r = 17
}else{
  pdf_width = 12
  mar_r = 15
}

if(ncol(data)>99){
  spa =0
}else{
  total_spa = (-0.56*ncol(data)+58)/100
  spa = (15*total_spa/ncol(data))/(15*(1-total_spa)/ncol(data))
}
max_sample_name_length = max(nchar(colnames(data)))
if(ncol(data)<=10 && max_sample_name_length<=5){
  srt=0
  pt.cex=3
}else if(ncol(data)<=10 && max_sample_name_length<=10){
  srt=45
  pt.cex=3
}else if(ncol(data)<=10 && max_sample_name_length>10){
  srt=60
  pt.cex=2
}else if(ncol(data)>10){
  srt=90
  pt.cex=2
}

y.value = max(apply(data,2,sum))/10
if(title.infor=="1"){
pdf(outfilepdf,height=6,width=pdf_width)
temp.mar <- par("mar")
temp.mar[4] <- temp.mar[4]+mar_r
par(mar=temp.mar)
temp <- barplot(as.matrix(data),col=gcolor,font=2,space=spa,xaxt='n')
text(temp,y = -y.value,srt=srt,labels=colnames(data),xpd=T)
mtext('Relative Abundance',side=2,line=3,cex=1.1,font=2)
mtext(paste0("Level",title.infor," Abundance barplot"), side=3, line=1, cex=1.1,font=2)
legend(x=max(temp)+min(temp),y=y.value*7,pch=15, col=gcolor,legend=rownames(data), bty="n",
       pt.cex=pt.cex, cex=1, x.intersp=1.2, y.intersp=2,xpd=TRUE)
}else{
pdf(outfilepdf,height=10,width=pdf_width)
temp.mar <- par("mar")
temp.mar[1] <- temp.mar[1]+mar_r*1.5
par(mar=temp.mar)
temp <- barplot(as.matrix(data),col=gcolor,font=2,space=spa,xaxt='n')
text(temp,y = -y.value,srt=srt,labels=colnames(data),xpd=T)
mtext('Relative Abundance',side=2,line=3,cex=1.1,font=2)
mtext(paste0("Level",title.infor," Abundance barplot"), side=3, line=1, cex=1.1,font=2)

legend(x=0,y=-y.value*5,pch=15, col=gcolor,legend=rownames(data), bty="n",
       pt.cex=pt.cex, cex=1, x.intersp=1.2, y.intersp=2,xpd=TRUE,ncol=2)

}
dev.off()

