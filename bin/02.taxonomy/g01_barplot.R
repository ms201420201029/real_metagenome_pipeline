source('/data_center_01/pipeline/16S_ITS_pipeline_v3.0/src/template/labels2colors.R')
data <- read.table('@#{infile}',header=TRUE,row.names=1,sep='\t', check.names=F,quote="")
data <- data[c(attributes(sort(apply(data,1,sum)[-nrow(data)],decreasing=T))$names,"Other"),]
tax_num = nrow(data)


if(tax_num < (@#{top}+2)){
    cols = cols_brewer[1:tax_num-1]
    cols[tax_num] = '#000000'
}else{
    cols = cols_brewer[1:@#{top}]
    cols[(@#{top}+1):tax_num] = '#000000'

}

font_size = 2
pdf_width = 15
max_sample_name_length = max(mapply(nchar,colnames(data)))
max_legend_name_length = max(mapply(nchar,rownames(data)))
width = 5
if(max_legend_name_length > 29){
  layout_width=1
}else{
  layout_width = -2/13*max_legend_name_length+5.46153846
}
if(tax_num>0 && tax_num<10){
    hei = 7
}else if(tax_num>=10 && tax_num<15){
#    hei = 1/3*12/21*tax_num+20/3
    hei = 12
}else if(tax_num>=15 && tax_num<21){
    hei = ceiling(12/21*tax_num)
}else{
    hei = 12
}

pdf('@#{pdf_file}',height=hei,width=pdf_width)
if(max_sample_name_length < 10){
  bottom_mar = 8+5
}else{
  bottom_mar = (max_sample_name_length-10)*font_size*0.5 + 8+5
}


if(ncol(data)<=10 && max_sample_name_length<=5){
  srt=45
}else if(ncol(data)<=10 && max_sample_name_length<=10){
  srt=45
}else if(ncol(data)<=10 && max_sample_name_length>10){
  srt=60
}else if(ncol(data)>10){
  srt=90
}
if(ncol(data)>99){
  spa =0
}else{
  total_spa = (-0.56*ncol(data)+58)/100
  spa = (15*total_spa/ncol(data))/(15*(1-total_spa)/ncol(data))
}

bar_plot <- function(lmat = lmat, lhei = lhei, lwid = lwid,bottom_mar = bottom_mar,data = data,
                     cols = cols,spa = spa,width = width,from_factor = NULL,ncol = ncol,
                     mar_left = NULL,mar_right =NULL,srt=srt,mar_legend_bottom=NULL,mar_legend_top=NULL,
                     x.intersp=NULL,y.intersp=NULL,pt.cex=NULL){
  nf <- layout(lmat, widths = lwid, heights =lhei, respect = FALSE)
  #layout.show(nf)
  if (missing(mar_left) || is.null(mar_left)) {
    mar_left = 11
  }
  if (missing(mar_right) || is.null(mar_right)) {
    mar_right = 4
  }
  if (missing(mar_legend_bottom) || is.null(mar_legend_bottom)) {
    mar_legend_bottom = bottom_mar
  }
  if (missing(mar_legend_top) || is.null(mar_legend_top)) {
    mar_legend_top = 6
  }
  if (missing(from_factor) || is.null(from_factor)) {
    from_factor = 1.5
  }
  if (missing(x.intersp) || is.null(x.intersp)) {
    x.intersp = 1.2
  }
  if (missing(y.intersp) || is.null(y.intersp)) {
    y.intersp = 2
  }
  if (missing(pt.cex) || is.null(pt.cex)) {
    pt.cex = 5
  }


  par(mar=c(bottom_mar,mar_left,6,mar_right))
  if(ncol(data)==1){
    barplot(as.matrix(data),col=cols,xaxt='n',font=2,space=spa,width=width,xlim=c(3,15),cex.axis =2)
  }else if(ncol(data)>1 && ncol(data)<=10){
    barplot(as.matrix(data),col=cols,xaxt='n',font=2,space=spa,width=width,cex.axis = 2)
  }else{
    barplot(as.matrix(data),col=cols,xaxt='n',font=2,space=spa,width=width,cex.axis = 3)
  }
  if(ncol(data) == 1){
    text(9.5,srt=srt, adj=1, labels=colnames(data),
         xpd=T, cex=font_size, y=-5)
    mtext('Relative Abundance(%)',side=2,line=5,cex=font_size*0.9,font=2)
    mtext('@#{title}', side=3, line=1, cex=font_size*1.1,,font=2)
  }else if(ncol(data)<=10){
    text(seq(from=from_factor*spa*width, length=ncol(data), by=1*spa*width+width),
         srt=srt, adj=1, labels=colnames(data),
         xpd=T, cex=font_size, y=-5)
    mtext('Relative Abundance(%)',side=2,line=5,cex=font_size*0.9,font=2)
    mtext('@#{title}', side=3, line=1, cex=font_size*1.1,font=2)
  }else if(ncol(data)>10 && ncol(data)<=50){
    text(seq(from=from_factor*spa*width, length=ncol(data), by=1*spa*width+width),
         srt=srt, adj=1, labels=colnames(data),
         xpd=T, cex=font_size, y=-5)
    mtext('Relative Abundance(%)',side=2,line=5,cex=font_size*1.1,font=2)
    mtext('@#{title}', side=3, line=1, cex=font_size*1.1,font=2)
  }else if(ncol(data)>50 && ncol(data)<=100){
    text(seq(from=from_factor*spa*width, length=ncol(data), by=1*spa*width+width),
         srt=srt, adj=1, labels=colnames(data),
         xpd=T, cex=font_size*0.8, y=-5)
    mtext('Relative Abundance(%)',side=2,line=5,cex=font_size*1.1,font=2)
    mtext('@#{title}', side=3, line=1, cex=font_size*1.1,font=2)
  }else if(ncol(data)>100 && ncol(data)<=145){
    text(seq(from=from_factor*spa*width, length=ncol(data), by=1*spa*width+width),
         srt=srt, adj=1, labels=colnames(data),
         xpd=T, cex=font_size*0.6, y=-5)
    mtext('Relative Abundance(%)',side=2,line=5,cex=font_size*1.1,font=2)
    mtext('@#{title} Level Barplot', side=3, line=1, cex=font_size*1.1,font=2)
  }else{
    text(seq(from=from_factor*spa*width, length=ncol(data), by=1*spa*width+width),
         srt=srt, adj=1, labels=colnames(data),
         xpd=T, cex=font_size*0.3, y=-5)
    mtext('Relative Abundance(%)',side=2,line=5,cex=font_size*1.1,font=2)
    mtext('@#{title} Level Barplot', side=3, line=1, cex=font_size*1.1,font=2)
  }

  par(mar=c(mar_legend_bottom,0,mar_legend_top,0))
  plot(0, type="n", bty="n", xaxt="n", yaxt="n", xlab="",ylab="")
  if(tax_num < (@#{top}+2)){
  legend("top", pch=15, col=cols, legend=rownames(data), bty="n",
         pt.cex=pt.cex, cex=2, ncol=ncol, x.intersp=x.intersp, y.intersp=y.intersp,xpd=TRUE)
  }else{
  legend("top", pch=15, col=cols, legend=c(attributes(sort(apply(data,1,sum)[-nrow(data)],decreasing=T))$names[1:@#{top}],"Other"), bty="n",
         pt.cex=pt.cex, cex=2, ncol=ncol, x.intersp=x.intersp, y.intersp=y.intersp,xpd=TRUE)
  }





}


def.par <- par(no.readonly=TRUE)
if(ncol(data)>0 && ncol(data)<=1){
  ncol = ceiling( tax_num / 21)
  y.intersp=1
  pt.cex=3
  bar_plot(lmat = matrix(c(1,2),1,2,byrow=TRUE), lhei = c(1,1), lwid = c(layout_width,1),bottom_mar=bottom_mar,data=data,cols=cols,spa=spa,width=width,from_factor = 1.5,ncol = ncol,srt=srt,y.intersp=y.intersp,pt.cex=pt.cex)

}else if(ncol(data)>1 && ncol(data)<=2){
  spa = spa*3
  ncol = ceiling( tax_num / 21)
  from_factor = 1.3
  y.intersp=1
  pt.cex=3
  bar_plot(lmat = matrix(c(1,2),1,2,byrow=TRUE), lhei = c(1,1), lwid = c(layout_width,1),bottom_mar=bottom_mar,data=data,cols=cols,spa=spa,width=width,from_factor = from_factor,ncol = ncol,srt=srt,y.intersp=y.intersp,pt.cex=pt.cex)

}else if(ncol(data)>2 && ncol(data)<=4){
  ncol = ceiling( tax_num / 21)
  from_factor = 1.8
  y.intersp=1
  pt.cex=3
  bar_plot(lmat = matrix(c(1,2),1,2,byrow=TRUE), lhei = c(1,1), lwid = c(layout_width,1),bottom_mar=bottom_mar,data=data,cols=cols,spa=spa,width=width,from_factor = from_factor,ncol = ncol,srt=srt,y.intersp=y.intersp,pt.cex=pt.cex)

}else if(ncol(data)>4 && ncol(data)<=10){
  ncol = 1
  srt = srt
  y.intersp=1.05
  pt.cex=3
  bar_plot(lmat = matrix(c(1,2),1,2,byrow=TRUE), lhei = c(1,1), lwid = c(layout_width,1),bottom_mar=bottom_mar,data=data,cols=cols,spa=spa,width=width,ncol = ncol,srt=srt,y.intersp=y.intersp,pt.cex=pt.cex)

}else if(ncol(data)>10 && ncol(data)<=30){
  mar_right=40-ncol(data)
  mar_left=40-ncol(data)
  ncol = ceiling( tax_num / 7)
  mar_legend_top = 0
  bar_plot(lmat = matrix(c(1,1,2),3,1,byrow=TRUE), lhei = c(1,1,1),lwid = c(1),bottom_mar=bottom_mar,data=data,cols=cols,spa=spa,width=width,ncol = ncol,srt=srt,mar_left = mar_left,mar_right =mar_right,mar_legend_top = mar_legend_top)

}else{
  ncol = ceiling( tax_num / 7)
  mar_legend_top = 0
  bar_plot(lmat = matrix(c(1,1,2),3,1,byrow=TRUE), lhei = c(1,1,1),lwid = c(1),bottom_mar=bottom_mar,data=data,cols=cols,spa=spa,width=width,ncol = ncol,srt=srt,mar_legend_top = mar_legend_top )
}

par(def.par)
dev.off()

