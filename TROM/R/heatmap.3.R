heatmap.3 <-
function(x,
                      max_score = 6, 
                      Rowv = TRUE, 
                      Colv = if (symm) "Rowv" else TRUE, 
                      distfun = dist, 
                      hclustfun = hclust, 
                      dendrogram = c("both", "row", "column", "none"), 
                      symm = FALSE, 
                      scale = c("none", "row", "column"), 
                      na.rm = TRUE, 
                      revC = identical(Colv, "Rowv"), 
                      add.expr, 
                      breaks, 
                      symbreaks = min(x < 0, na.rm = TRUE) || scale != "none", col = "heat.colors", 
                      colsep, 
                      rowsep, 
                      sepcolor = "white", 
                      sepwidth = c(0.05, 0.05), 
                      cellnote, 
                      notecex = 1, 
                      notecol = "cyan", 
                      na.color = par("bg"), 
                      #trace = c("column", "row", "both", "none"), 
                      trace = c("none"), 
                      tracecol = "cyan", 
                      hline = median(breaks), 
                      vline = median(breaks), 
                      linecol = tracecol, 
                      margins = c(5, 5), 
                      ColSideColors, 
                      RowSideColors, 
                      cexRow = 0.2 + 1/log10(nr), 
                      cexCol = 0.2 + 1/log10(nc), 
                      labRow = NULL, 
                      labCol = NULL, 
                      key = TRUE, 
                      keysize = 1.5, 
                      density.info = c("histogram", "density", "none"), 
                      denscol = tracecol, 
                      symkey = min(x < 0, na.rm = TRUE) || symbreaks, 
                      densadj = 0.25, 
                      main = NULL, 
                      xlab = NULL, 
                      ylab = NULL, 
                      lmat = NULL, 
                      lhei = NULL, 
                      lwid = NULL, 
                      leftMargin=7, 
                      bottomMargin=7, 
                      reverse=FALSE,
                      ...){
  nr <- dim(x)[1]
  nc <- dim(x)[2]
  if (dendrogram == c("none")){
    heatmap.3.noddg(x=x, max_score=max_score, Rowv=Rowv, Colv=Colv, distfun=distfun, 
                    hclustfun=hclustfun, dendrogram=dendrogram, symm=symm, 
                    scale=scale, na.rm=na.rm, revC=revC, add.expr=add.expr, 
                    breaks=breaks, symbreaks=symbreaks, col=col, colsep=colsep, 
                    rowsep=rowsep, sepcolor=sepcolor, sepwidth=sepwidth, cellnote=cellnote, 
                    notecex=notecex, notecol=notecol, 
                    na.color=na.color, trace=trace, tracecol=tracecol, hline=hline, 
                    vline=vline, linecol=linecol, margins=margins, 
                    ColSideColors=ColSideColors, RowSideColors=RowSideColors, 
                    cexRow=cexRow, cexCol=cexCol, labRow=labRow, labCol=labCol, 
                    key=key, keysize=keysize, density.info=density.info, denscol=denscol, 
                    symkey=symkey, densadj=densadj, main=main, xlab=xlab, ylab=ylab, 
                    lmat=lmat, lhei=lhei, lwid=lwid, 
                    leftMargin=leftMargin, bottomMargin=bottomMargin, reverse=reverse,
                    ...)
  }else{
    heatmap.3.ddg(x=x, max_score=max_score, Rowv=Rowv, Colv=Colv, distfun=distfun, 
                  hclustfun=hclustfun, dendrogram=dendrogram, symm=symm, 
                  scale=scale, na.rm=na.rm, revC=revC, add.expr=add.expr, 
                  breaks=breaks, col=col, colsep=colsep, 
                  rowsep=rowsep, sepcolor=sepcolor, sepwidth=sepwidth, cellnote=cellnote, 
                  notecex=notecex, notecol=notecol, 
                  na.color=na.color, trace=trace, tracecol=tracecol, hline=hline, 
                  vline=vline, linecol=linecol, margins=margins, 
                  ColSideColors=ColSideColors, RowSideColors=RowSideColors, 
                  cexRow=cexRow, cexCol=cexCol, labRow=labRow, labCol=labCol, 
                  key=key, keysize=keysize, density.info=density.info, denscol=denscol, 
                  densadj=densadj, main=main, xlab=xlab, ylab=ylab, 
                  lmat=lmat, lhei=lhei, lwid=lwid, 
                  ...)
  }
}
