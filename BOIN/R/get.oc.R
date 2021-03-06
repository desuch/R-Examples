#'
#' Generate operating characteristics for single agent trials
#'
#' Obtain the operating characteristics of the BOIN design for single agent trials by simulating trials.
#'
#' @usage get.oc(target, p.true, ncohort, cohortsize, n.earlystop=100,
#'               startdose=1, p.saf="default", p.tox="default", cutoff.eli=0.95,
#'               extrasafe=FALSE, offset=0.05, ntrial=1000)
#'
#' @param target the target toxicity rate
#' @param p.true a vector containing the true toxicity probabilities of the
#'              investigational dose levels.
#' @param ncohort the total number of cohorts
#' @param cohortsize the cohort size
#' @param n.earlystop the early stopping parameter. If the number of patients
#'                    treated at the current dose reaches \code{n.earlystop},
#'                    stop the trial and select the MTD based on the observed data.
#'                    The default value \code{n.earlystop=100} essentially turns
#'                    off this type of early stopping.
#' @param startdose the starting dose level for the trial
#' @param p.saf the highest toxicity probability that is deemed subtherapeutic
#'              (i.e. below the MTD) such that dose escalation should be undertaken.
#'              The default value is \code{p.saf=0.6*target}.
#' @param p.tox the lowest toxicity probability that is deemed overly toxic such
#'              that deescalation is required. The default value is \code{p.tox=1.4*target}).
#' @param cutoff.eli the cutoff to eliminate an overly toxic dose for safety.
#'                  We recommend the default value of (\code{cutoff.eli=0.95}) for general use.
#' @param extrasafe set \code{extrasafe=TRUE} to impose a more stringent stopping rule
#' @param offset a small positive number (between 0 and 0.5) to control how strict the
#'               stopping rule is when \code{extrasafe=TRUE}. A larger value leads to a more
#'               strict stopping rule. The default value \code{offset=0.05} generally works well.
#' @param ntrial the total number of trials to be simulated.
#'
#' @details The operating characteristics of the BOIN design are generated by simulating trials
#'          under the prespecified true toxicity probabilities of the investigational doses.
#'          The BOIN design has two built-in stopping rules: (1) stop the trial if the lowest
#'          dose is eliminated due to toxicity, and no dose should be selected as the MTD; and
#'          (2) stop the trial and select the MTD if the number of patients treated at the current
#'          dose reaches \code{n.earlystop}. The first stopping rule is a safety rule to protect patients
#'          from the case in which all doses are overly toxic. The rationale for the second stopping
#'          rule is that when there is a large number (i.e., \code{n.earlystop}) of patients
#'          assigned to a dose, it means that the dose-finding algorithm has approximately converged.
#'          Thus, we can stop the trial early and select the MTD to save sample size and reduce the
#'          trial duration. For some applications, investigators may prefer a more strict safety
#'          stopping rule than rule (1) for extra safety when the lowest dose is overly toxic.
#'          This can be achieved by setting \code{extrasafe=TRUE}, which imposes the following more
#'          strict safety stopping rule: stop the trial if (i) the number of patients treated at the
#'          lowest dose \code{>=3}, and (ii) Pr(toxicity rate of the lowest dose > \code{target} | data)
#'          > \code{cutoff.eli-offset}. As a tradeoff, the strong stopping rule will decrease the MTD
#'          selection percentage when the lowest dose actually is the MTD.
#'
#' @return \code{get.oc()} returns the operating characteristics of the BOIN design as a data frame,
#'         including: (1) selection percentage at each dose level (\code{selpercent}),
#'         (2) the number of patients treated at each dose level (\code{nptsdose}),
#'         (3) the number of toxicities observed at each dose level (\code{ntoxdose}),
#'         (4) the average number of toxicities (\code{totaltox}),
#'         (5) the average number of patients (\code{totaln}),
#'         and (6) the percentage of early stopping without selecting the MTD (\code{pctearlystop}).
#'
#' @export
#'
#' @note We should avoid setting the values of \code{p.saf} and \code{p.tox} very close to the \code{target}.
#'       This is because the small sample sizes of typical phase I trials prevent us from
#'       differentiating the target toxicity rate from the rates close to it. In addition,
#'       in most clinical applications, the target toxicity rate is often a rough guess,
#'       and finding a dose level with a toxicity rate reasonably close to the target rate
#'       will still be of interest to the investigator. The default values provided by
#'       \code{get.oc()} are generally reasonable for most clinical applications.
#'
#' @author Suyu Liu and Ying Yuan
#'
#' @references Liu S. and Yuan, Y. (2015). Bayesian Optimal Interval Designs for Phase I
#'             Clinical Trials, Journal of the Royal Statistical Society: Series C, 64, 507-523.
#'
#' @seealso Tutorial: \url{http://odin.mdacc.tmc.edu/~yyuan/Software/BOIN/BOIN2.2_tutorial.pdf}
#'
#'          Paper: \url{http://odin.mdacc.tmc.edu/~yyuan/Software/BOIN/paper.pdf}
#'
#' @examples
#' get.oc(target=0.3, p.true=c(0.05, 0.15, 0.3, 0.45, 0.6), ncohort=1000, cohortsize=3, ntrial=1000)
#'
get.oc <- function(target, p.true, ncohort, cohortsize, n.earlystop=100, startdose=1,
                   p.saf="default", p.tox="default", cutoff.eli=0.95, extrasafe=FALSE,
                   offset=0.05, ntrial=1000){
## if the user does not provide p.saf and p.tox, set them to the default values
	if(p.saf=="default") p.saf=0.6*target;
	if(p.tox=="default") p.tox=1.4*target;

## simple error checking
	if(target<0.05) {cat("Error: the target is too low! \n"); return();}
	if(target>0.6)  {cat("Error: the target is too high! \n"); return();}
	if((target-p.saf)<(0.1*target)) {cat("Error: the probability deemed safe cannot be higher than or too close to the target! \n"); return();}
	if((p.tox-target)<(0.1*target)) {cat("Error: the probability deemed toxic cannot be lower than or too close to the target! \n"); return();}
	if(offset>=0.5) {cat("Error: the offset is too large! \n"); return();}
    if(n.earlystop<=6) {cat("Warning: the value of n.earlystop is too low to ensure good operating characteristics. Recommend n.earlystop = 9 to 18 \n"); return();}

	set.seed(6);
	ndose=length(p.true);
	npts = ncohort*cohortsize;
	Y=matrix(rep(0, ndose*ntrial), ncol=ndose); # store toxicity outcome
	N=matrix(rep(0, ndose*ntrial), ncol=ndose); # store the number of patients
	dselect = rep(0, ntrial); # store the selected dose level

## obtain dose escalation and deescalation boundaries
	temp=get.boundary(target, ncohort, cohortsize, n.earlystop, p.saf, p.tox, cutoff.eli, extrasafe, print=FALSE);
	b.e=temp[2,];   # escalation boundary
	b.d=temp[3,];   # deescalation boundary
	b.elim=temp[4,];  # elimination boundary


################## simulate trials ###################
	for(trial in 1:ntrial)
	{
		y<-rep(0, ndose);    ## the number of DLT at each dose level
		n<-rep(0, ndose);    ## the number of patients treated at each dose level
		earlystop=0;         ## indiate whether the trial terminates early
		d=startdose;         ## starting dose level
		elimi = rep(0, ndose);  ## indicate whether doses are eliminated

		for(i in 1:ncohort)
		{
### generate toxicity outcome
			y[d] = y[d] + sum(runif(cohortsize)<p.true[d]);
			n[d] = n[d] + cohortsize;

            if(n[d]>=n.earlystop) break;

## determine if the current dose should be eliminated
			if(!is.na(b.elim[n[d]]))
			{
				if(y[d]>=b.elim[n[d]])
				{
					elimi[d:ndose]=1;
					if(d==1) {earlystop=1; break;}
				}
## implement the extra safe rule by decreasing the elimination cutoff for the lowest dose
				if(extrasafe)
				{
					if(d==1 && y[1]>=3)
					{
						if(1-pbeta(target, y[1]+1, n[1]-y[1]+1)>cutoff.eli-offset) {earlystop=1; break;}
					}
				}
			}

## dose escalation/de-escalation
			if(y[d]<=b.e[n[d]] && d!=ndose) { if(elimi[d+1]==0) d=d+1; }
			else if(y[d]>=b.d[n[d]] && d!=1) { d=d-1; }
			else { d=d; }
		}
		Y[trial,]=y;
		N[trial,]=n;
		if(earlystop==1) { dselect[trial]=99; }
		else  { dselect[trial]=select.mtd(target, n, y, cutoff.eli, extrasafe, offset, print=FALSE); }
	}

# output results
	selpercent=rep(0, ndose);
    nptsdose = apply(N,2,mean);
    ntoxdose = apply(Y,2,mean);

	for(i in 1:ndose) { selpercent[i]=sum(dselect==i)/ntrial*100; }
	cat("selection percentage at each dose level (%):\n");
	cat(formatC(selpercent, digits=1, format="f"), sep="  ", "\n");
	cat("number of patients treated at each dose level:\n");
	cat(formatC(nptsdose, digits=1, format="f"), sep ="  ", "\n");
	cat("number of toxicity observed at each dose level:\n");
	cat(formatC(ntoxdose, digits=1, format="f"), sep ="  ", "\n");
	cat("average number of toxicities:", formatC(sum(Y)/ntrial, digits=1, format="f"), "\n");
	cat("average number of patients:", formatC(sum(N)/ntrial, digits=1, format="f"), "\n");
	cat("percentage of early stopping due to toxicity:", formatC(sum(dselect==99)/ntrial*100, digits=1, format="f"), "% \n");

	if(length(which(p.true==target))>0) # if MTD exist
	{
		cat("risk of poor allocation:", formatC(mean(N[, p.true==target]<npts/ndose)*100, digits=1, format="f"), "% \n");
		cat("risk of high toxicity:", formatC(mean(rowSums(Y)>target*npts)*100, digits=1, format="f"), "% \n");
	}

    invisible(data.frame(target=target, p.true=p.true, ncohort=ncohort, cohortsize = cohortsize,
    ntotal=ncohort*cohortsize, startdose = startdose, p.saf = p.saf, p.tox = p.tox,
    cutoff.eli = cutoff.eli, extrasafe = extrasafe, offset = offset, ntrial = ntrial,
    dose=1:ndose, selpercent=selpercent, nptsdose=nptsdose, ntoxdose=ntoxdose, totaltox=sum(Y)/ntrial, totaln=sum(N)/ntrial, pctearlystop=sum(dselect== 99)/ntrial * 100))
}
