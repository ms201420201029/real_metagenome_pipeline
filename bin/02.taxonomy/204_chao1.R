args <- commandArgs("T")
source('/data_center_01/pipeline/16S_ITS_pipeline_v3.0/src/template/labels2colors.R')
table = read.table(args[1], sep = "\t",head = T, check.names=F,quote="")
table = table[,-which(colnames(table)=="reads")]
group=read.table(args[2], sep = "\t",head = F,row.names=1, check.names=F,quote="")
color_list = group2corlor(group)
sample_colors = color_list[[1]]
group_colors =  color_list[[2]]
group_names =   color_list[[3]]
group = color_list[[4]]
group_names_max_length=max(mapply(nchar,group_names))
if(group_names_max_length>0 && group_names_max_length<=2){
	xlim_add = 1800
}else if(group_names_max_length>2 && group_names_max_length<=4){
	xlim_add = 5000
}else{
	xlim_add = 10000
}
pdf(args[3])
par(mar=c(5.1,5.1,3.1,2.1))

readnumber = as.numeric(rownames(table))
if(ncol(table)==1){
  g_order=group[,1]
  gcols_order="red"
  ymax=max(as.numeric(as.character(table[,4][table[,1] != "n/a"])))
  
  # plot blank canvas
  plot(0,0,xlim=c(0,max(readnumber)+xlim_add),ylim=c(0,ymax),type="n",xlab="reads",ylab="shannon",cex.lab=1.4)
 
    legend("topright",legend=g_order,col=gcols_order,seg.len=1.5,lwd=1.6,cex=0.8) 

  
  # fitting function
  otu <- function(reads, vmax, km){
    vmax * reads / (km + reads)
  }
  

    col = table[,1]
    col = as.numeric(as.character(col[col != "n/a"]))
    readnum = readnumber[1:length(col)]
    color="red"
    min = Inf
    for(km in c(10,1000,4000,10000)){
      estimation <- tryCatch(
        nls(col~otu(readnum, vmax, km), start=list( vmax = max(col), km=km),lower=c(0,0.2),algorithm = "port"),
        error=function(e) e
      )
      if(class(estimation)[1] == 'simpleError'){
        next
      }
      if(min > deviance(estimation)){
        min = deviance(estimation)
        min_estimation = estimation
      }
    }
    estimation = min_estimation
    x = seq(0,max(readnum), max(readnum)/1000)
    y = otu(x, coef(estimation)[1], coef(estimation)[2])
    lines(x,y,col=color,lwd=2)

}else{
#	table = table[,-c(1)]
	table = table[,rownames(group)]
	which(table[table != "n/a"]==NA)
	ymax=max(as.numeric(as.character(table[table != "n/a"])))
	print(ymax)
	# plot blank canvas
	plot(0,0,xlim=c(0,max(readnumber)+xlim_add),ylim=c(0,ymax+5000),type="n",xlab="reads",ylab="rarefaction",cex.lab=1.4)
	if( length( group_names ) <= 20){ 
		legend("topright",legend=group_names,col=group_colors,seg.len=1.5,lwd=1.6,cex=0.8) 
	}

	# fitting function
	otu <- function(reads, vmax, km){
		vmax * reads / (km + reads)
	}

	for(i in 1:ncol(table))
	{
	  col = table[,i]
	  col = as.numeric(as.character(col[col != "n/a"]))
	  readnum = readnumber[1:length(col)]
	  color=sample_colors[i]
	  min = Inf
	  for(km in c(10,1000,4000,10000)){
	    estimation <- tryCatch(
			nls(col~otu(readnum, vmax, km), start=list( vmax = max(col), km=km),lower=c(0,0.2),algorithm = "port"),
			error=function(e) e
		)
		if(class(estimation)[1] == 'simpleError'){
			next
		}
	    if(min > deviance(estimation)){
			min = deviance(estimation)
			min_estimation = estimation
	    }
 	 }
	  estimation = min_estimation
	  x = seq(0,max(readnum), max(readnum)/1000)
	  y = otu(x, coef(estimation)[1], coef(estimation)[2])
	  lines(x,y,col=color,lwd=2)
	}
}


dev.off()
png(args[4],width = 1440, height = 1440, units = "px",pointsize = 36,type = c("cairo"))
par(mar=c(5.1,5.1,3.1,2.1))
if(ncol(table)==1){
  g_order = group[,1]
  # plot blank canvas
  plot(0,0,xlim=c(0,max(readnumber)+xlim_add),ylim=c(0,ymax+5000),type="n",xlab="reads",ylab="shannon",cex.lab=1.4)
 
    legend("topright",legend=g_order,col=gcols_order,seg.len=1.5,lwd=1.6,cex=0.8) 

  
  # fitting function
  otu <- function(reads, vmax, km){
    vmax * reads / (km + reads)
  }
    col = table[,1]
    col = as.numeric(as.character(col[col != "n/a"]))
    readnum = readnumber[1:length(col)]
    color="red"
    min = Inf
    for(km in c(10,1000,4000,10000)){
      estimation <- tryCatch(
        nls(col~otu(readnum, vmax, km), start=list( vmax = max(col), km=km),lower=c(0,0.2),algorithm = "port"),
        error=function(e) e
      )
      if(class(estimation)[1] == 'simpleError'){
        next
      }
      if(min > deviance(estimation)){
        min = deviance(estimation)
        min_estimation = estimation
      }
    }
    estimation = min_estimation
    x = seq(0,max(readnum), max(readnum)/1000)
    y = otu(x, coef(estimation)[1], coef(estimation)[2])
    lines(x,y,col=color,lwd=2)

}else{
	ymax=max(as.numeric(as.character(table[table != "n/a"])))
	# plot blank canvas
	plot(0,0,xlim=c(0,max(readnumber)+xlim_add),ylim=c(0,ymax+5000),type="n",xlab="reads",ylab="rarefaction",cex.lab=1.4)
	if( length( group_names ) <= 20){ 
		legend("topright",legend=group_names,col=group_colors,seg.len=1.5,lwd=1.6,cex=0.8) 
	}

	# fitting function
	otu <- function(reads, vmax, km){
		vmax * reads / (km + reads)
	}

	for(i in 1:ncol(table))
	{
	  col = table[,i]
	  col = as.numeric(as.character(col[col != "n/a"]))
	  readnum = readnumber[1:length(col)]
	  color=sample_colors[i]
	  min = Inf
	  for(km in c(10,1000,4000,10000)){
	    estimation <- tryCatch(
			nls(col~otu(readnum, vmax, km), start=list( vmax = max(col), km=km),lower=c(0,0.2),algorithm = "port"),
			error=function(e) e
		)
		if(class(estimation)[1] == 'simpleError'){
			next
		}
	    if(min > deviance(estimation)){
			min = deviance(estimation)
			min_estimation = estimation
	    }
 	 }
	  estimation = min_estimation
	  x = seq(0,max(readnum), max(readnum)/1000)
	  y = otu(x, coef(estimation)[1], coef(estimation)[2])
	  lines(x,y,col=color,lwd=2)
	}
}

dev.off()
