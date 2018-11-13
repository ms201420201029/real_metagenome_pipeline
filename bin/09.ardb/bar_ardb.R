data = read.table("ardb.class.modified.profile",head = TRUE)
data_H = data[,1:83]
data_P = data[,84:156]
avg_H = apply(data_H,1,mean)
avg_P = apply(data_P,1,mean)
avg = apply(data,1,mean)
o = rev(order(avg))
data.plot = rbind(avg_H,avg_P)
data.plot = data.plot[,o]
palette = c("red", "gray", "cornflowerblue", "chartreuse3", "yellow", "honeydew4", "indianred4", "khaki", "lightblue1", "lightseagreen", "lightslateblue", "magenta", "blue", "orange2", "purple", "black")
pdf("bar_ardb.pdf")
barplot(t(data.plot),col=palette,xlim=c(0.3,10),ylab="Relative abundance (%)",legend.text=rownames(data)[o],names.arg=c("Health\nControl","Ankylosing\nsporidylitis"),cex.names=1,space=0.5)
dev.off()
