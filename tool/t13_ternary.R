source("{{ tool_default_dir }}/labels2colors.R")
profile.file <- "{{ profile_table }}"
group.file <- "{{ group_file }}"
pdf.file = "{{ pdf_file }}"
class <- "{{ class_ }}"

#profile.file = "F:\\R\\02.04.ternaryplot\\species.profile"
#group.file <- "F:\\R\\02.04.ternaryplot\\all_group.list"
#pdf.file <- "F:\\R\\02.04.ternaryplot\\ternaryplot.pdf"
#class <- "Species"
#source('F:\\R\\pcoa\\labels2colors.R')
library(vcd)
profile.data <- read.table(profile.file, head = T, check.names = F,quote="",sep="\t",row.names=1);
group <- read.table(group.file, head = F, check.names = F, row.names = 1,quote="",sep="\t")
colors = c('#00447E','#F34800','#64A10E','#930026','#464E04','#049a0b','#4E0C66','#D00000','#FF6C00',
           '#FF00FF','#c7475b','#00F5FF','#BDA500','#A5CFED','#f0301c','#2B8BC3','#FDA100','#54adf5',
           '#CDD7E2','#9295C1',"#FF0000FF", "#FF9900FF", "#CCFF00FF", "#33FF00FF" ,"#00FF66FF", "#00FFFFFF" 
           ,"#0066FFFF" ,"#3300FFFF","#CC00FFFF","#FF0099FF")

profile <- profile.data[,rownames(group)]

color_list = group2corlor(group)
sample_colors = color_list[[1]]
group_colors  = color_list[[2]]
group_names = color_list[[3]]
group = color_list[[4]]
sample.list <- group[,1]

group1 = profile[sample.list==names(table(sample.list))[1]]
group2 = profile[sample.list==names(table(sample.list))[2]]
group3 = profile[sample.list==names(table(sample.list))[3]]


mean_1 = apply(group1, 1, mean)
profile1 <- group1[rev(order(mean_1))[1:10], ]
mean_2 = apply(group2, 1, mean)
profile2 <- group2[rev(order(mean_2))[1:10], ]
mean_3 = apply(group3, 1, mean)
profile3 <- group3[rev(order(mean_3))[1:10], ]

ys = c(rev(order(mean_1))[1:10],rev(order(mean_2))[1:10],rev(order(mean_3))[1:10])
profile_new = profile[ys[!duplicated(ys)],]
rownames(profile_new) = substr(rownames(profile_new),start = 4,stop = nchar(rownames(profile_new)))

test = rbind(apply(profile_new[sample.list==names(table(sample.list))[1]], 1, mean),
             apply(profile_new[sample.list==names(table(sample.list))[2]], 1, mean),
             apply(profile_new[sample.list==names(table(sample.list))[3]], 1, mean))

rownames(test) = names(table(sample.list))
# t(test)

test1 = (as.data.frame(test))


for(j in 1:length(test1)){
  sum_ = sum(test1[j])
  for(i in 1:3){
    test1[j][i,] = test1[j][i,] / sum_
  }
}
if (ncol(test1) < 10) {
  cex = 3
}else if (ncol(test1) < 20) {
  cex = 2
}else {
  cex = 1
}
pdf(pdf.file, width = 8, height = 6)
fa = as.factor(rownames(t(test1)))
par(mar=c(4.1,5.1,4.1,2.1))
nf<-layout(matrix(c(1,1,1,1,1,2,2,
                    1,1,1,1,1,2,2,
                    1,1,1,1,1,2,2,
                    1,1,1,1,1,2,2,
                    1,1,1,1,1,3,3),5,7,byrow=TRUE))

plot(0, type="n", bty="n", xaxt="n", yaxt="n", xlab="",ylab="")
ternaryplot(
  t(test1),
  pch = 20,
  col = colors[as.numeric(fa)],
  main = paste("Main", class, "in Groups"),
  labels = "outside",
  grid = 'dashed',
  cex = 2,
  prop_size = 1,newpage = FALSE
)
ternaryplot(
  t(test1),
  pch = 20,
  col = colors[as.numeric(fa)],
  main = paste("Main", class, "in Groups"),
  labels = "outside",
  grid = 'dashed',
  cex = 2,
  prop_size = 1,newpage = FALSE
)
plot(0, type="n", bty="n", xaxt="n", yaxt="n", xlab="",ylab="")

legend("top", pch=20, col=colors[as.numeric(fa)], legend=rownames(t(test1))[as.numeric(fa)], bty="n",
      pt.cex=3, cex=0.8, ncol=1, x.intersp=1.2, y.intersp=1.3,xpd=TRUE)
dev.off()



