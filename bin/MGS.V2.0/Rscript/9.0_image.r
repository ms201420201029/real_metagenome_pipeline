#args=c("final_group_members_profile_A.profile", "final_group_members_profile_H.profile", "final_group_mean_A.profile","final_group_mean_H.profile", 25, "fdr", "mgs")
args <- commandArgs("T")
if (length(args) != 7){
	stop("argument number error: $0 <2nd_grp1_gene_profile> <2nd_grp2_gene_profile> <2nd_grp1_mean_profile> <2nd_grp2_mean_profile> <gene_num> <grp1_list> <grp2_list>");
}

grp1_gene   <- read.table(args[1],quote="",check.names=F);
grp2_gene   <- read.table(args[2],quote="",check.names=F);
grp1_mean   <- read.table(args[3],quote="",check.names=F);
grp2_mean   <- read.table(args[4],quote="",check.names=F);
gene_num    <- as.numeric(args[5]);
prefix_grp1 <- args[6];
grp1_list   <- paste(prefix_grp1,".list",sep="");
prefix_grp2 <- args[7];
grp2_list   <- paste(prefix_grp2,".list",sep="");

row.names(grp1_mean) <- paste(prefix_grp1, 1:nrow(grp1_mean), sep="_");
row.names(grp2_mean) <- paste(prefix_grp2, 1:nrow(grp2_mean), sep="_");
profile_mean <- as.matrix(rbind(grp1_mean, grp2_mean));
profile_gene <- as.matrix(rbind(grp1_gene, grp2_gene));
grp1_sample  <- as.vector(t(read.table(grp1_list,check.names=F,quote="")));
grp2_sample  <- as.vector(t(read.table(grp2_list,check.names=F,quote="")));
grp1_order   <- which(colnames(profile_gene) %in% grp1_sample);
grp2_order   <- which(colnames(profile_gene) %in% grp2_sample);
interval     <- range(profile_gene);
profile_gene <- (profile_gene-interval[1])/(interval[2]-interval[1]);

#grp1_ranksum <- apply(apply(grp1_mean,1,rank),1,sum)
#grp2_ranksum <- apply(apply(grp2_mean,1,rank),1,sum)
grp1_ranksum <- apply(as.data.frame(apply(grp1_mean,1,rank))[grp1_sample,],1,sum)
grp2_ranksum <- apply(as.data.frame(apply(grp2_mean,1,rank))[grp2_sample,],1,sum)
grp1_mgsrank <- rev(order(as.vector(apply(as.data.frame(apply(grp1_mean,2,rank))[grp1_sample],1,sum))))
grp2_mgsrank <- order(as.vector(apply(as.data.frame(apply(grp2_mean,2,rank))[grp2_sample],1,sum)))
grp1_mgsname <- row.names(grp1_mean)[grp1_mgsrank]
grp2_mgsname <- row.names(grp2_mean)[grp2_mgsrank]

generank     <- c()
for(i in 1:length(grp1_mgsrank)){
  generank   <- c(generank,(gene_num*(grp1_mgsrank[i]-1)+1):(gene_num*grp1_mgsrank[i]))
}
for(i in 1:length(grp2_mgsrank)){
  generank   <- c(generank,(gene_num*(grp2_mgsrank[i]+length(grp1_mgsrank)-1)+1):(gene_num*(grp2_mgsrank[i]+length(grp1_mgsrank))))
}
#grp1_sort    <- rev(order(grp1_ranksum[grp1_order]))
#grp2_sort    <-     order(grp2_ranksum[grp2_order])
#grp1_sort    <- grp1_sample[rev(order(grp1_ranksum))]
#grp2_sort    <- grp2_sample[order(grp2_ranksum)]
#profile_gene <- profile_gene[generank,c(grp1_order[grp1_sort],grp2_order[grp2_sort])]
all_profile <- rbind(grp1_mean, grp2_mean)
profile_genesort <- matrix(ncol=length(c(grp1_sample,grp2_sample)),nrow=1)
for(i in 1:nrow(all_profile)){
  grp1_sort <- grp1_sample[rev(as.matrix(t(apply(all_profile[grp1_sample],1,order)))[i,])]
  grp2_sort <- grp2_sample[as.matrix(t(apply(all_profile[grp2_sample],1,order)))[i,]]
  profile_genesort <- rbind(profile_genesort,profile_gene[c(((i-1)*gene_num+1):(i*gene_num)),c(grp1_sort,grp2_sort)])
}
#profile_gene <- profile_gene[generank,c(grp1_sort,grp2_sort)]
profile_gene <- profile_genesort[generank,]

colfunc <- colorRampPalette(c("white","LightSeaGreen","yellow","orange","red","blue","black"),bias=4)
pdf("new_mgs.pdf", width=10, height=12);
par(mfcol=c(2,1),mar=c(2,4,1,7) )
layout(rbind(c(1),c(2)), heights = c(0.7, 8));
##color bar
par(mar=c(1.5,4,0,7) )
color_split = 1000
barplot(rep(0.9,1000),col=colfunc(1000),space=0,border=NA,axes=FALSE,ylim=c(0,1))
text(0   , -0.2, signif(interval[1],digit=3), adj=0.5, xpd=TRUE);
text(1000, -0.2, signif(interval[2],digit=3), adj=0.5, xpd=TRUE);
##heatmap
par(mar=c(3,6,0,7) )
image(1:ncol(profile_gene),1:nrow(profile_gene),z=t(profile_gene), col=colfunc(color_split), axe=F,xlab="", ylab="")
box()
y <- gene_num
line_y <- nrow(grp1_mean)*gene_num
while(y < nrow(profile_gene)){
  abline(y, 0)
  if(y==line_y){
	abline(y,0,lwd=3)
  }
  y <- y + gene_num
}
abline(v=length(grp1_order)+0.5, lwd=3)
##left p-values
p_values  <- apply(profile_mean,1,function(x,y=1:length(grp1_order),z=length(grp1_order)+1:length(grp2_order)) wilcox.test(unlist(x[y]),unlist(x[z]))$p.value)
p_values  <- signif(p_values,digits=3)
at_vector <- seq(0,nrow(profile_gene)-as.numeric(args[5]),as.numeric(args[5]))+as.numeric(args[5])/2
axis(4,at=at_vector,labels=p_values,las=1,cex.axis=0.8)
##right mgs id
#axis(2,at=at_vector,labels=rownames(profile_mean),las=1,cex.axis=0.7)
axis(2,at=at_vector,labels=c(grp1_mgsname,grp2_mgsname),las=1,cex.axis=0.7)
##bottom two group
mtext(prefix_grp1, side=1, line=1, at=length(grp1_order)/2);
mtext(prefix_grp2, side=1, line=1, at=length(grp2_order)/2+length(grp1_order));
dev.off();
