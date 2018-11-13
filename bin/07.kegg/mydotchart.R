mydotchart <- function (x, labels = NULL, groups = NULL, gdata = NULL, cex = par("cex"), 
  pt.cex = cex, pch = 21, gpch = 21, bg = par("bg"), color = par("fg"), 
  gcolor = par("fg"), lcolor = "gray", xlim = range(x[is.finite(x)]), 
  main = NULL, xlab = NULL, ylab = NULL, ...) 
{
  opar <- par("mai", "mar", "cex", "yaxs")
  on.exit(par(opar))
  par(cex = cex, yaxs = "i")
  if (!is.numeric(x)) 
    stop("'x' must be a numeric vector or matrix")
  n <- length(x)
  if (is.matrix(x)) {
    if (is.null(labels)) 
      labels <- rownames(x)
    if (is.null(labels)) 
      labels <- as.character(1L:nrow(x))
    labels <- rep_len(labels, n)
    if (is.null(groups)) 
      groups <- col(x, as.factor = TRUE)
    glabels <- levels(groups)
  }
  else {
    if (is.null(labels)) 
      labels <- names(x)
    glabels <- if (!is.null(groups)) 
      levels(groups)
    if (!is.vector(x)) {
      warning("'x' is neither a vector nor a matrix: using as.numeric(x)")
      x <- as.numeric(x)
    }
  }
  plot.new()
  linch <- if (!is.null(labels)) 
    max(strwidth(labels, "inch"), na.rm = TRUE)
  else 0
  if (is.null(glabels)) {
    ginch <- 0
    goffset <- 0
  }
  else {
    ginch <- max(strwidth(glabels, "inch"), na.rm = TRUE)
    goffset <- 0.4
  }
  if (!(is.null(labels) && is.null(glabels))) {
    nmai <- par("mai")
    nmai[2L] <- nmai[4L] + max(linch + goffset, ginch) + 
      0.1
    par(mai = nmai)
  }
  if (is.null(groups)) {
    o <- 1L:n
    y <- o
    ylim <- c(0, n + 1)
  }
  else {
    o <- sort.list(as.numeric(groups), decreasing = TRUE)
    x <- x[o]
    groups <- groups[o]
    color <- rep_len(color, length(groups))[o]
    lcolor <- rep_len(lcolor, length(groups))[o]
    offset <- cumsum(c(0, diff(as.numeric(groups)) != 0))
    y <- 1L:n + 2 * offset
    ylim <- range(0, y + 2)
  }
  plot.window(xlim = xlim, ylim = ylim, log = "",xaxt="n")
  #axis(1,at=c(10000,20000,30000,40000,50000,60000),labels = c("1e+5","2e+5","3e+5","4e+5","5e+5","6e+5"),las=3,srt=30)
  text(x = c(10000,20000,30000), y = rep(-1,3), labels = c("1e+5","2e+5","3e+5"), srt = 30, adj = 1, cex = 1.2, xpd = T)
  lheight <- par("csi")
  if (!is.null(labels)) {
    linch <- max(strwidth(labels, "inch"), na.rm = TRUE)
    loffset <- (linch + 0.1)/lheight
    labs <- labels[o]
    mtext(labs, side = 2, line = loffset, at = y, adj = 0, 
      col = color, las = 2, cex = pt.cex/cex*0.8, ...)
  }
  abline(h = y, lty = "dotted", col = lcolor,cex = 0.003)
  rect(0,y-cex/2,x,y+cex/2,col = color,bg = bg,cex = pt.cex/cex)
  #points(x, y, pch = pch, col = color, bg = bg, cex = pt.cex/cex)
  text(x+xlim*2/100, y+cex/10,labels=x, col = color, bg = bg, cex = pt.cex/cex*0.8,adj=0)
  if (!is.null(groups)) {
    gpos <- rev(cumsum(rev(tapply(groups, groups, length)) + 
      2) - 1)
    ginch <- max(strwidth(glabels, "inch"), na.rm = TRUE)
    goffset <- (max(linch + 0.2, ginch, na.rm = TRUE) + 
      0.1)/lheight
    mtext(glabels, side = 2, line = goffset, at = gpos, 
      adj = 0, col = gcolor, las = 2, cex = cex,font=2, ...)
    if (!is.null(gdata)) {
      abline(h = gpos, lty = "dotted")
      points(gdata, gpos, pch = gpch, col = gcolor, bg = bg, 
        cex = pt.cex/cex, ...)
    }
  }
 
  box()
  title(main = main, xlab = xlab, ylab = ylab, ...)
  invisible()
}
