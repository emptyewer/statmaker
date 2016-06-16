runMCMC <- function(Data, outfile="mcmc.RData", n.chains=4, debug=TRUE) {
  # Setup
  ng <- dim(Data$Vector)[1]
  nvr <- dim(Data$Vector)[3]
  monitor <- c('gamma')
  if (Data$arrayBait) {
    nb <- dim(Data$Bait)[3]
    jData <- with(Data, list(v=Vector, y=Bait, ng=ng, nb=nb, nvr=nvr, ytr=btr, vtr=vtr, omega=omega))
    model <- system.file("model/sModel2.jag", package="deepn")
    nsig <- 2 + nb
  } else {
    jData <- with(Data, list(v=Vector, y=Bait, ng=ng, nvr=nvr, ytr=btr, vtr=vtr, omega=omega))
    model <- system.file("model/sModel1.jag", package="deepn")
    nsig <- 3
  }
  FUN <- function(chain) {list(log.sigma=runif(nsig))}
  inits <- mapply(FUN, 1:n.chains, SIMPLIFY=FALSE)

  runjags.options(rng.warning=FALSE)
  jagsfit <- run.jags(model, monitor=monitor, data=jData, inits=inits, n.chains=n.chains,
                      method="rjparallel", adapt=1500, burnin=1500, sample=1500, summarise=FALSE)
  save(jagsfit, Data, file=outfile)
}