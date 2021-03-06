filter_unsp<-function(h,...){
	f<-function(h,...){
			x<<-svalue(h$obj)
			}
		try(({
		dat2Affy.m<-dat2Affy.m;datAgOne2.m<-datAgOne2.m;datAgTwo2.m<-datAgTwo2.m;datIllBA2.m2<-datIllBA2.m2;
		lumi_NQ.m<-lumi_NQ.m;data.matrix_Nimblegen2.m<-data.matrix_Nimblegen2.m;
		data.matrixNorm.m<-data.matrixNorm.m;data.matrix_onlineNorm.m<-data.matrix_onlineNorm.m;l<-l;tree<-tree;
			}),silent=TRUE)
		platforms=NULL;
		aa=0;bb=0;cc=0;dd=0;ee=0;ff=0;gg=0;hh=0;
		try(({
			if(exists("dat2Affy.m"))aa=length(dat2Affy.m)
			if(exists("datAgOne2.m"))bb=length(datAgOne2.m)
			if(exists("datAgTwo2.m"))cc=length(datAgTwo2.m)
			if(exists("datIllBA2.m2"))dd=length(datIllBA2.m2)
			if(exists("lumi_NQ.m"))ee=length(lumi_NQ.m)
			if(exists("data.matrix_Nimblegen2.m"))ff=length(data.matrix_Nimblegen2.m)
			if(exists("data.matrixNorm.m"))gg=length(data.matrixNorm.m)
			if(exists("data.matrix_onlineNorm.m"))hh=length(data.matrix_onlineNorm.m)
			}),silent=TRUE)
		if(aa!=0)platforms=c(platforms,"Affymetrix")
		if(bb!=0)platforms=c(platforms,"Agilent_OneColor")
		if(cc!=0)platforms=c(platforms,"Agilent_TwoColor")
		if(dd!=0)platforms=c(platforms,"Illumina_Beadarray")
		if(ee!=0)platforms=c(platforms,"Illumina_Lumi")
		if(ff!=0)platforms=c(platforms,"Nimblegen")
		if(gg!=0)platforms=c(platforms,"Series_Matrix")
		if(hh!=0)platforms=c(platforms,"Online_Data")

		dat2Affy.f=NULL;datAgOne2.f=NULL;datAgTwo2.f=NULL;datIllBA2.f=NULL;lumi_NQ.f=NULL;
		data.matrix_Nimblegen2.f=NULL;data.matrixNorm.f=NULL;data.matrix_onlineNorm.f=NULL;
		dgeF=NULL;
		dgeS<-function(h,...){
			dgeF<-NULL
			rsd<-rowSds(h)
			i<-rsd>=2
			dat.f<-h[i,]
			fit<-lmFit(dat.f)
			yy<-try(toptable(fit,coef=2),silent=TRUE)
			if(length(grep("Error in",yy))!=0){
			fit2<-eBayes(fit)
			}else{
				fit2<-eBayes(fit)
				}
			dgeF<<-fit2
		}
		dgeE<-function(h,...){
			dgeF<-NULL
			ff<-pOverA(A=1,p=0.5)
			i<-genefilter(h,ff)
			dat.fo<-h[i,]
			i<-genefilter(-h,ff)
			dat.fu<-h[i,]
			dat.f<-rbind(dat.fo,dat.fu)
			fit<-lmFit(dat.f)
			yy<-try(toptable(fit,coef=2),silent=TRUE)
			if(length(grep("Error in",yy))!=0){
			fit2<-eBayes(fit)
			}else{
				fit2<-eBayes(fit)
				}
			dgeF<<-fit2
		}
	rm(dat2Affy.f,datAgOne2.f,datAgTwo2.f,datIllBA2.f,lumi_NQ.f,
		data.matrix_Nimblegen2.f,data.matrixNorm.f,data.matrix_onlineNorm.f)

	x=NULL
	z=NULL
	unsf_xx=NULL
	unsf_methods=c("Standard_Deviation_Filter","Expression_Filter")
	unsf_w<-gwindow("Select a Filter",width=300,height=150)
	unsf_gp<-ggroup(container=unsf_w,horizontal=FALSE)
	unsf_x<-gtable(unsf_methods,chosencol=1,container=unsf_gp)
	size(unsf_x)=c(200,100)
	unsf_gp2<-ggroup(container=unsf_gp,width=30,height=15,horizontal=TRUE)
	addHandlerClicked(unsf_x,handler=function(h,...){
		unsf_x2<-svalue(h$obj)
		unsf_xx<<-unsf_x2
		}
	)
	addSpring(unsf_gp2)
	unsf_y<-gbutton("CANCEL",border=TRUE,handler=function(h,...){
		dispose(unsf_w)
		},container=unsf_gp2,anchor=c(1,-1)
	)
	unsf_y2<-gbutton("OK",border=TRUE,handler=function(h,...){
		dispose(unsf_w)
		svalue(sb)<-"Working... Plz wait..."
		Sys.sleep(1)
		if(unsf_xx=="Standard_Deviation_Filter")
		{
			w_f<-gwindow("Select your data",width=260,height=280,visible=FALSE)
			gp_f<-ggroup(container=w_f,horizontal=FALSE)
			size(gp_f)=c(220,180)
			cbg<-gcheckboxgroup(platforms,container=gp_f,handler=f)
			svalue(cbg,index=FALSE)<-1:8
			gp2_f<-ggroup(container=gp_f,width=30,height=15,horizontal=TRUE)
			addSpring(gp2_f)
			y<-gbutton("CANCEL",border=TRUE,handler=function(h,...){
				dispose(w_f)
				},container=gp2_f,anchor=c(1,-1))
			y2<-gbutton("OK",border=TRUE,handler=function(h,...){
				if(length(x)!=0){
					dispose(w_f)
					if(length(which(x=="Affymetrix"))!=0){
						dgeS(dat2Affy.m)
						dat2Affy.f<<-dgeF
						dgeF=NULL
						if(length(dat2Affy.f)!=0){
							visible(g1_1)<-FALSE
							l$Affymetrix$Filtered<<-list()
							tr<<-gtree(offspring=tree,container=g1_1)
							size(tr)<-c(300,400)
							visible(g1_1)<-TRUE
							stat_sign(dat2Affy.f)						
							}
							display()
						}
					if(length(which(x=="Agilent_OneColor"))!=0){
						dgeS(datAgOne2.m)
						datAgOne2.f<<-dgeF
						dgeF=NULL
						if(length(datAgOne2.f)!=0){
							visible(g1_1)<-FALSE
							l$Agilent_OneColor$Filtered<<-list()
							tr<<-gtree(offspring=tree,container=g1_1)
							size(tr)<-c(300,400)
							visible(g1_1)<-TRUE
							stat_sign(datAgOne2.f)				
							}
							display()
						}
					if(length(which(x=="Agilent_TwoColor"))!=0){
						dgeS(datAgTwo2.m)
						datAgTwo2.f<<-dgeF
						dgeF=NULL
						if(length(datAgTwo2.f)!=0){
							visible(g1_1)<-FALSE
							l$Agilent_TwoColor$Filtered<<-list()
							tr<<-gtree(offspring=tree,container=g1_1)
							size(tr)<-c(300,400)
							visible(g1_1)<-TRUE
							stat_sign(datAgTwo2.f)							
							}
							display()
						}
					if(length(which(x=="Illumina_Beadarray"))!=0){
						dgeS(datIllBA2.m2)
						datIllBA2.f<<-dgeF
						dgeF=NULL
						if(length(datIllBA2.f)!=0){
							visible(g1_1)<-FALSE
							l$Illumina_Beadarray$Filtered<<-list()
							tr<<-gtree(offspring=tree,container=g1_1)
							size(tr)<-c(300,400)
							visible(g1_1)<-TRUE
							stat_sign(datIllBA2.f)							
							}
							display()
						}
					if(length(which(x=="Illumina_Lumi"))!=0){
						dgeS(lumi_NQ.m)
						lumi_NQ.f<<-dgeF
						dgeF=NULL
						if(length(lumi_NQ.f)!=0){
							visible(g1_1)<-FALSE
							l$Illumina_Lumi$Filtered<<-list()
							tr<<-gtree(offspring=tree,container=g1_1)
							size(tr)<-c(300,400)
							visible(g1_1)<-TRUE
							stat_sign(lumi_NQ.f)						
							}
							display()
						}
					if(length(which(x=="Nimblegen"))!=0){
						dgeS(data.matrix_Nimblegen2.m)
						data.matrix_Nimblegen2.f<<-dgeF
						dgeF=NULL
						if(length(data.matrix_Nimblegen2.f)!=0){
							visible(g1_1)<-FALSE
							l$Nimblegen$Filtered<<-list()
							tr<<-gtree(offspring=tree,container=g1_1)
							size(tr)<-c(300,400)
							visible(g1_1)<-TRUE
							stat_sign(data.matrix_Nimblegen2.f)							
							}
							display()
						}
					if(length(which(x=="Series_Matrix"))!=0){
						dgeS(data.matrixNorm.m)
						data.matrixNorm.f<<-dgeF
						dgeF=NULL
						if(length(data.matrixNorm.f)!=0){
							visible(g1_1)<-FALSE
							l$Series_Matrix$Filtered<<-list()
							tr<<-gtree(offspring=tree,container=g1_1)
							size(tr)<-c(300,400)
							visible(g1_1)<-TRUE
							stat_sign(data.matrixNorm.f)							
							}
							display()
						}
					if(length(which(x=="Online_Data"))!=0){
						dgeS(data.matrix_onlineNorm.m)
						data.matrix_onlineNorm.f<<-dgeF
						dgeF=NULL
						stat_sign(data.matrix_onlineNorm.f)
						if(length(data.matrix_onlineNorm.f)!=0){
							visible(g1_1)<-FALSE
							l$Online_Data$Filtered<<-list()
							tr<<-gtree(offspring=tree,container=g1_1)
							size(tr)<-c(300,400)
							visible(g1_1)<-TRUE
							data.matrix_onlineNorm.f=NULL							
							}
							display()
						}
					dispose(w_f)
					}else{
					gmessage("Plz select the data for filtering","Select Data")
					}
				},container=gp2_f,anchor=c(1,-1))
			visible(w_f)<-TRUE
			}
		else if(unsf_xx=="Expression_Filter")
		{
			w_f<-gwindow("Select your data",width=260,height=280,visible=FALSE)
			gp_f<-ggroup(container=w_f,horizontal=FALSE)
			size(gp_f)=c(220,180)
			cbg<-gcheckboxgroup(platforms,container=gp_f,handler=f)
			svalue(cbg,index=FALSE)<-1:8
			gp2_f<-ggroup(container=gp_f,width=30,height=15,horizontal=TRUE)
			addSpring(gp2_f)
			y<-gbutton("CANCEL",border=TRUE,handler=function(h,...){
				dispose(w_f)
				},container=gp2_f,anchor=c(1,-1))
			y2<-gbutton("OK",border=TRUE,handler=function(h,...){
				if(length(x)!=0){
					dispose(w_f)
					if(length(which(x=="Affymetrix"))!=0){
						dgeE(dat2Affy.m)
						dat2Affy.f<<-dgeF
						dgeF=NULL
						if(length(dat2Affy.f)!=0){
							visible(g1_1)<-FALSE
							l$Affymetrix$Filtered<<-list()
							tr<<-gtree(offspring=tree,container=g1_1)
							size(tr)<-c(300,400)
							visible(g1_1)<-TRUE
							stat_sign(dat2Affy.f)							
							}
							display()
						}
					if(length(which(x=="Agilent_OneColor"))!=0){
						dgeE(datAgOne2.m)
						datAgOne2.f<<-dgeF
						dgeF=NULL
						if(length(datAgOne2.f)!=0){
							visible(g1_1)<-FALSE
							l$Agilent_OneColor$Filtered<<-list()
							tr<<-gtree(offspring=tree,container=g1_1)
							size(tr)<-c(300,400)
							visible(g1_1)<-TRUE
							stat_sign(datAgOne2.f)								
							}
							display()
						}
					if(length(which(x=="Agilent_TwoColor"))!=0){
						dgeE(datAgTwo2.m)
						datAgTwo2.f<<-dgeF
						dgeF=NULL
						if(length(datAgTwo2.f)!=0){
							visible(g1_1)<-FALSE
							l$Agilent_TwoColor$Filtered<<-list()
							tr<<-gtree(offspring=tree,container=g1_1)
							size(tr)<-c(300,400)
							visible(g1_1)<-TRUE
							stat_sign(datAgTwo2.f)							
							}
							display()
						}
					if(length(which(x=="Illumina_Beadarray"))!=0){
						dgeE(datIllBA2.m2)
						datIllBA2.f<<-dgeF
						dgeF=NULL
						if(length(datIllBA2.f)!=0){
							visible(g1_1)<-FALSE
							l$Illumina_Beadarray$Filtered<<-list()
							tr<<-gtree(offspring=tree,container=g1_1)
							size(tr)<-c(300,400)
							visible(g1_1)<-TRUE
							stat_sign(datIllBA2.f)							
							}
							display()
						}
					if(length(which(x=="Illumina_Lumi"))!=0){
						dgeE(lumi_NQ.m)
						lumi_NQ.f<<-dgeF
						dgeF=NULL
						if(length(lumi_NQ.f)!=0){
							visible(g1_1)<-FALSE
							l$Illumina_Lumi$Filtered<<-list()
							tr<<-gtree(offspring=tree,container=g1_1)
							size(tr)<-c(300,400)
							visible(g1_1)<-TRUE
							stat_sign(lumi_NQ.f)							
							}
							display()
						}
					if(length(which(x=="Nimblegen"))!=0){
						dgeE(data.matrix_Nimblegen2.m)
						data.matrix_Nimblegen2.f<<-dgeF
						dgeF=NULL
						stat_sign(data.matrix_Nimblegen2.f)
						if(length(data.matrix_Nimblegen2.f)!=0){
							visible(g1_1)<-FALSE
							l$Nimblegen$Filtered<<-list()
							tr<<-gtree(offspring=tree,container=g1_1)
							size(tr)<-c(300,400)
							visible(g1_1)<-TRUE
							data.matrix_Nimblegen2.f=NULL							
							}
							display()
						}
					if(length(which(x=="Series_Matrix"))!=0){
						dgeE(data.matrixNorm.m)
						data.matrixNorm.f<<-dgeF
						dgeF=NULL
						if(length(data.matrixNorm.f)!=0){
							visible(g1_1)<-FALSE
							l$Series_Matrix$Filtered<<-list()
							tr<<-gtree(offspring=tree,container=g1_1)
							size(tr)<-c(300,400)
							visible(g1_1)<-TRUE
							stat_sign(data.matrixNorm.f)							
							}
							display()
						}
					if(length(which(x=="Online_Data"))!=0){
						dgeE(data.matrix_onlineNorm.m)
						data.matrix_onlineNorm.f<<-dgeF
						dgeF=NULL
						stat_sign(data.matrix_onlineNorm.f)
						if(length(data.matrix_onlineNorm.f)!=0){
							visible(g1_1)<-FALSE
							l$Online_Data$Filtered<<-list()
							tr<<-gtree(offspring=tree,container=g1_1)
							size(tr)<-c(300,400)
							visible(g1_1)<-TRUE
							data.matrix_onlineNorm.f=NULL							
							}
							display()
						}
					dispose(w_f)
					}else{
					gmessage("Plz select the data for filtering","Select Data")
					}
				},container=gp2_f,anchor=c(1,-1))
			visible(w_f)<-TRUE
			}
		svalue(sb)<-"Done"
		},container=unsf_gp2,anchor=c(1,-1)
	)
}	

