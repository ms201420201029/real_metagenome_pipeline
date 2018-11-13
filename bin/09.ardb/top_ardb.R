source('/home/liulf/real_metagenome_test/tool/labels2colors.R')

args <- commandArgs("T")
profile.file <- args[1]
group.file <- args[2]
pdf.file <- args[3]

#profile.file = "F:\\R\\09.argb\\ardb.profile"
#group.file <- "F:\\R\\09.argb\\group.txt"
#pdf.file <- "F:\\R\\09.argb\\top_ardb.pdf"

profile.data <- read.table(profile.file, check.names = F, header = T,row.names = 1,quote="",sep="\t")
group <- read.table(group.file, check.names = F, row.names = 1)
profile.data <- profile.data[,rownames(group)]

color_list = group2corlor(group)
sample_colors = color_list[[1]]
group_colors  = color_list[[2]]
group_names = color_list[[3]]
group = color_list[[4]]
sample.list <- group[,1]

data_H = profile.data[sample.list==names(table(sample.list))[1]]
data_P = profile.data[sample.list==names(table(sample.list))[2]]

data_H.median = apply(data_H,1,median);
data_P.median = apply(data_P,1,median);
data_H.o = rev(order(data_H.median))[1:10];
data_P.o = rev(order(data_P.median))[1:10];

common = data_H.o[which(data_H.o %in% data_P.o)];
data_H.oo = data_H.o[-which(data_H.o %in% data_P.o)];
data_P.oo = data_P.o[-which(data_P.o %in% data_H.o)];

pdf(pdf.file,height=10,width=10);
ylim_min = min(data_H[common,],data_P[common,])/10
ylim_max = max(data_H[common,],data_P[common,])*5

#ylim=c(ylim_min,ylim_max)
boxplot(t(data_H[common,]),boxwex=0.3,at=2*(1:length(common))-1,ylim=c(10^-8,ylim_max),xlim=c(0,21),
            border=group_colors[1],log="y",xaxt="n",yaxt="n",pch=20,cex=0.5,ylab="Relative abundance (log10)");
boxplot(t(data_P[common,]),boxwex=0.3,at=2*(1:length(common)),border=group_colors[2],
            log="y",xaxt="n",yaxt="n",pch=20,cex=0.5,add=TRUE);
boxplot(t(data_H[data_H.oo,]),boxwex=0.6,at=(2*length(common)+1:(10-length(common))),
            border=group_colors[1],log="y",add=TRUE,xaxt="n",yaxt="n",pch=20,cex=0.5);
boxplot(t(data_P[data_P.oo,]),boxwex=0.6,at=((10+length(common)+1):20),add = TRUE,
            border=group_colors[2],log="y",xaxt="n",yaxt="n",pch=20,cex=0.5);

text(labels=dimnames(data_H[common,])[[1]],x=2*(1:length(common))-1,y=rep(4.5*10^-9,10),srt=90,xpd=TRUE,adj=1);
text(labels=dimnames(data_H[common,])[[1]],x=2*(1:length(common)),y=rep(4.5*10^-9,10),srt=90,xpd=TRUE,adj=1);
text(labels=dimnames(data_H[data_H.oo,])[[1]],x=(2*length(common)+1:(10-length(common))),y=rep(4.5*10^-9,10),srt=90,xpd=TRUE,adj=1);
text(labels=dimnames(data_P[data_P.oo,])[[1]],x=((10+length(common)+1):20),y=rep(4.5*10^-9,10),srt=90,xpd=TRUE,adj=1);
axis(1,labels=FALSE,at=(1:20));
axis(2,labels=(-8:-2),at=c(10^-8,10^-7,10^-6,10^-5,10^-4,10^-3,10^-2));

legend("topright",legend=group_names,col=group_colors,pch=15);
for(i in 1:length(common)){
  p_value = wilcox.test(unlist(data_H[common[i],]),unlist(data_P[common[i],]))$p.value;
  p_value = format(p_value,scientific=T,digit=3);
  height = max(data_H[common[i],],data_P[common[i],])*1.5;
  segments(x0=2*i-1,y0=height*1.2,x1=2*i,y1=height*1.2);
  segments(x0=2*i-1,y0=height,x1=2*i-1,y1=height*1.2);
  segments(x0=2*i,y0=height,x1=2*i,y1=height*1.2);
  text(x=2*i-0.5,y=height*1.2,labels=p_value,pos=3);
}

dev.off();
