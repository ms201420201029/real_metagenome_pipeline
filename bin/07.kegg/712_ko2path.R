source("/data_center_01/pipeline/real_metagenome/real_metagenome_v1.0.0/tool/labels2colors.R")
outdir = "{{ outdir }}"
data = read.table("{{ kocuntfile }}",header = T,row.names = 1,sep="\t",quote="",check.names = F)
pdf(file = paste0(outdir,"/ko2path.pdf"),height = 13,width = 10)
mar_tmp <- par("mar")
mar_tmp[1] <- mar_tmp[1]*max(nchar(rownames(data)))/25
layout(matrix(c(1,2),2,1))
par(mar=mar_tmp)
temp = barplot(t(data),las=1,beside = T,xaxt="n",col = cols_brewer[1:ncol(data)],legend=colnames(data),ylab="The number of KO")
text(x=colMeans(temp),y=-max(data[,1])/100,rownames(data),srt=60,xpd=T,adj =1,cex=0.5)
len=length(colnames(data))
reldata=data
for (i in 1:len){
     reldata[,i]=reldata[,i]/sum(reldata[,i])
     }
write.table(reldata,"{{ outdir }}/kopercent.txt",sep='\t',quote = F)
par(mar=mar_tmp)
temp = barplot(t(reldata),las=1,beside = T,xaxt="n",col = cols_brewer[1:ncol(reldata)],legend=colnames(reldata),ylab="Percent of KO")
text(x=colMeans(temp),y=-max(reldata[,1])/100,rownames(reldata),srt=60,xpd=T,adj =1,cex=0.5)
dev.off()
