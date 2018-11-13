args <- commandArgs("T")

source('/home/liulf/real_metagenome_test/tool/labels2colors.R')
library("ggplot2")
library("ggpubr")
library("reshape2")
library("ggsignif")
data = read.table(args[1],header=F,row.names=1,check.names=F,fill=T,quote="")
pdf(args[2])
data_m <- melt(t(data))
data_m <- data_m[complete.cases(data_m),]
colnames(data_m) <- c("index","group","value")

groups = rownames(data)
cols = labels2colors(groups)

p <- ggboxplot(data_m, x="group", y="value", fill = cols,width = 0.5,size = 0.8,
               xlab = FALSE,ylab = "Abundance",font.y=20,add = "jitter",shape = "group",palette =cols)

p <- p + scale_x_discrete(limits=rownames(data)) + theme(legend.position='none',panel.border = element_rect(linetype = 1, fill = NA, size = 1.6))+
  labs(title = "", x = "", y= expression(paste("Gene number")))+
  theme(plot.title = element_text(size=20,hjust=0.5))+ scale_y_log10(breaks = scales::trans_breaks("log10",function(x) 10^x),labels=scales::trans_format("log10",scales::math_format(10^.x)))


my_comparisons <- list()
for(i in 1:(nrow(data)-1)){
  for(j in (i+1):nrow(data)){
    comp <- c(rownames(data)[i],rownames(data)[j])
    my_comparisons <- c(my_comparisons,list(comp))
  }
}

group_num = length(groups)

if(group_num==2){
  p+geom_signif(comparisons = my_comparisons, test = wilcox.test, step_increase = 0.16, textsize =4.5, map_signif_level = F)+
    stat_compare_means(size = 5,label.x = 0.66,label.y =log(max(data_m$value)+(max(data_m$value)-min(data_m$value)))/2.35)
}else if(group_num==3){
  p+geom_signif(comparisons = my_comparisons, test = wilcox.test, step_increase = 0.16, textsize =4.5, map_signif_level = F)+
    stat_compare_means(size = 5,label.x = 0.76,label.y =log(max(data_m$value)+(max(data_m$value)-min(data_m$value)))/2.27)
  
}else if(group_num==4){
  p+geom_signif(comparisons = my_comparisons, test = wilcox.test, step_increase = 0.16, textsize =4.5, map_signif_level = F)+
    stat_compare_means(size = 5,label.x = 0.9,label.y =log(max(data_m$value)+(max(data_m$value)-min(data_m$value)))/2.13)
  
}else if(group_num==5){
  p+geom_signif(comparisons = my_comparisons, test = wilcox.test, step_increase = 0.16, textsize =4.5, map_signif_level = F)+
    stat_compare_means(size = 5,label.x = 1,label.y =log(max(data_m$value)+(max(data_m$value)-min(data_m$value)))/1.97)
  
}else if(group_num==6){
  p+geom_signif(comparisons = my_comparisons, test = wilcox.test, step_increase = 0.16, textsize =4.5, map_signif_level = F)+
    stat_compare_means(size = 5,label.x = 1,label.y =log(max(data_m$value)+(max(data_m$value)-min(data_m$value)))/1.8)
}else if(group_num==7){
  p+geom_signif(comparisons = my_comparisons, test = wilcox.test, step_increase = 0.16, textsize =4.5, map_signif_level = F)+
    stat_compare_means(size = 5,label.x = 1.1,label.y =log(max(data_m$value)+(max(data_m$value)-min(data_m$value)))/1.64)
}else{
  p+geom_signif(comparisons = my_comparisons, test = wilcox.test, step_increase = 0.16, textsize =4.5, map_signif_level = F)+
    stat_compare_means(size = 5,label.x = 1.1,label.y =log(max(data_m$value)+(max(data_m$value)-min(data_m$value)))/1.64)
}
dev.off()