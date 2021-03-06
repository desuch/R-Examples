OptInit.alpha<-function(mbig,msmall,Rmat,c.objective){
  a<-rep(1,mbig)
  bl<-c(rep(0,mbig),msmall)
  bu<-c(rep(1,mbig),msmall)
  nclin<-1
  istate <- rep(0, mbig + nclin)
  storage.mode(a)<-"double"
  storage.mode(bl)<-"double"
  storage.mode(bu)<-"double"
  storage.mode(c.objective)<-"double"
  storage.mode(istate)<-"integer"
  storage.mode(Rmat)<-"double"
  lenw<-2*mbig*mbig+10*mbig+6
  alpha<-rep(1,mbig)*msmall/mbig
  storage.mode(alpha)<-"double"
  fit<-.Fortran("lssol",
              mn=as.integer(mbig),
              n=as.integer(mbig),
              nclin=as.integer(nclin),
              ldA=as.integer(nclin),
              ldR=as.integer(mbig),
              A=a,
              bl,
              bu,
              cvec=c.objective,
              istate=istate,
              kx=integer(mbig),
              x=as.double(alpha),
              R=Rmat,
              b=double(mbig),
              inform=integer(1),
              iter=integer(1),
              obj=double(1),
              clambda=double(mbig+nclin),
              iw=integer(mbig),
              leniw=as.integer(mbig),
              w=double(lenw),
              lenw=as.integer(lenw),
              PACKAGE="svmpath"
              )
  list(alpha=fit$x,obj=fit$obj)
}
