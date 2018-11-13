#if(length(args)<2){stop("Rscript 711_diff.R input.txt group.txt outputdir wilcox pvalue")}

profile.table <- "{{ profile_table }}"
group.file <- "{{ group_file }}"
out.dir <- "{{ out_dir }}"
mothed <- "{{ mothed }}"
p_cutoff <- {{ p_cutoff }}
fdr <- {{ fdr }}
paired <- {{ paired }}
data<-read.table(profile.table,header=T,sep="\t",row.names=1,check.names=F,quote="")
group<-read.table(group.file,header=F,row.names=1,check.names=F,quote="")
data <- data[,rownames(group)]
data<-as.matrix(data)
group_num <- nrow(unique(group))
group<-group[colnames(data),1]
group<-as.data.frame(group)
rownames(group)<-colnames(data)
g<-unique(group)
g_order<-g[order(g),1]
p<-c()
means<-c()
meanname<-c()
glist<-c()
xlist<-c()
for(i in 1:length(g_order)){
    rname<-which(group[,1]==g_order[i])
    g0=rownames(group)[rname]
    g0=g0[!is.na(g0)]
    mean=apply(data, 1, function(row) unlist(median(as.matrix(row[g0]),na.rm=T)))
    means=cbind(means,mean)
    meanname=c(meanname,paste("median(",g_order[i],")",sep=""))
    g1=list(as.character(g0))
    glist=c(glist,g1)
}
kruskal=function(data,group,g){
    p=c()
    for(i in 1:nrow(data)){
        xlist=c()
        for(j in 1:length(g_order)){
            rname=which(group[,1]==g_order[j])
            g0=rownames(group)[rname]
            g0=g0[!is.na(g0)]
            datag=list(data[i,g0])
            xlist=c(xlist,datag)
        }
        p0=kruskal.test(xlist)["p.value"][[1]][1]
        p=c(p,p0)
    }
    p
}
if(mothed=="t"){
    if(group_num==2){
    	#p <- apply(data, 1, function(row) unlist(t.test(row[glist[[1]]],row[glist[[2]]],paired=paired,alternative=c("two.sided", "less", "greater")[3])["p.value"]))
		p <- apply(data, 1, function(row) unlist(t.test(row[glist[[1]]],row[glist[[2]]],paired=paired)["p.value"]))
    }
}else{
    if(group_num==2){
    	#p <- apply(data, 1, function(row) unlist(wilcox.test(row[glist[[1]]],row[glist[[2]]],paired=paired,alternative=c("two.sided", "less", "greater")[3])["p.value"]))
		p <- apply(data, 1, function(row) unlist(wilcox.test(row[glist[[1]]],row[glist[[2]]],paired=paired)["p.value"]))
    }else{
    	p<-kruskal(data,group,g_order)
    }
}
fdr <- p.adjust(p, method = "fdr", n = length(p))
enrichment = apply(means,1,function(x) g_order[order(x,decreasing = T)[1]])
statsKWs<-data.frame(rownames(data),means,p,fdr,enrichment)
ploc=ncol(statsKWs)
colnames(statsKWs)<- c("taxonname",meanname,"pvalue","fdr","enrichment")
write.table(statsKWs,paste0(out.dir,"/diff.marker.tsv"),row.names=F,quote=F,sep="\t")

write.table(statsKWs[which(statsKWs[,group_num+2]<p_cutoff),],paste0(out.dir,"/diff.marker.filter.tsv"),row.names=F,quote=F,sep="\t")

write.table(data[rownames(statsKWs[which(statsKWs[,group_num+2]<p_cutoff),]),],paste0(out.dir,"/diff.marker.filter.profile.tsv"),quote=F,sep="\t")
