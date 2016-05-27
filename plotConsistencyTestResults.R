library(Hmisc)
# Make a plot of cL/S/M-test results as in RELM I: First-order results. For each 
# model, plot the 95% acceptance region as horizontal error bars abt the 
# forecast expectation. Plot the observed LL as
# a circle. If the circle falls outside the acceptance region, plot it in red,
# otherwise green.
plotConsistencyTestResults <- function(sTest) {
  print(sTest)
  vModels <- rev(c('akinci-lombardi.HAZGRIDX', 'akinci.HAZFX_BPT', 'chan.HZA_TD',
               'chan.HZA_TI', 'console-murru-falcone.LTST', 'faenza.PHM_Grid', 
               'faenza.PHM_Zone', 'gulia-wiemer.ALM', 'gulia-wiemer.HALM', 
               'lombardi.DBM', 'meletti.MPS04', 'meletti.MPS04after', 'nanjo.RI', 
               'peruzza-pace-visini.LASSCI', 'schorlemmer-wiemer.ALM_IT', 
               'werner.HiResSmoSeis-m1', 'werner.HiResSmoSeis-m2', 
               'zechar.TripleS-CPTI', 'zechar.TripleS-CSI', 
               'zechar.TripleS-hybrid'))
  vModelNicknames <- rev(c('akg', 'akb', 'chd', 'chi', 'con', 'fag', 'faz', 'gua', 
                       'guh', 'lom', 'mel', 'mea', 'nan', 'per', 'sch', 'wm1', 
                       'wm2', 'zep', 'zes','zeh'))
  vModelLabels <- rev(c('HAZGRIDX', 'HAZFX_BPT ', 'HZA_TD', 'HZA_TI', 'LTST', 
                       'PHM_Grid', 'PHM_Zone', 'ALM', 'HALM', 'DBM', 'MPS04', 
                       'MPS04a', 'RI', 'LASSCI', 'ALM.IT', 'HiResSmoSeis-m1', 
                       'HiResSmoSeis-m2', 'TripleS-CPTI', 'TripleS-CSI',
                       'TripleS-Hybrid'))
  
  sResultPath <- paste0('results/consistency/', sTest, '/')
  sSimProbsPath <- 'results/consistency/simulated log probabilities of forecasts/for cL, M, S tests/'
  if (sTest == 's'){
    sSimProbsPath <- paste0(sSimProbsPath, 'space-reduced/')
  }
  if (sTest == 'm'){
    sSimProbsPath <- paste0(sSimProbsPath, 'magnitude-reduced/')
  }  
  
  iModels <- length(vModels)
  vLowers <- rep(NA, iModels)
  vUppers <- rep(NA, iModels)
  vExpectations <- rep(NA, iModels)
  vObservations <- rep(NA, iModels)
  
  for (i in 1:iModels){
    model <- vModels[i]
    sModelNickname <- vModelNicknames[i]
    sResultFile <- paste0(sResultPath, '/catalogProbNAndP_', sModelNickname, 
                          '.rds')
    vResults <- readRDS(sResultFile)
    fProb <- vResults[1]
    N <- vResults[3]
    vObservations[i] <- fProb
    sSimulationFile <- paste0(sSimProbsPath, 'simProbs_', sModelNickname, '_',
                              N, '.rds')
    vSimulations <- readRDS(sSimulationFile)
    vLowers[i] <- sort(vSimulations)[floor(0.05*length(vSimulations))]
    vUppers[i] <- max(vSimulations)
    vExpectations[i] <- median(vSimulations)
    print(paste(sModelNickname, vResults[2]))
  }
  vBlanks <-rep("", iModels)
#   errbar(vModelLabels, vExpectations, vLowers, vUppers, pch=3)
  errbar(vBlanks, vExpectations, vLowers, vUppers, pch=3)
  
  
  title(paste0(sTest, "-Test"), xlab = "log-likelihood")
  # find and denote the models that fail the test
  vFailedIndices <- which(vObservations < vLowers)
  vPassedIndices <- which(vObservations >= vLowers)
  points(vObservations[vFailedIndices], vFailedIndices, pch=1, col="red", cex=3, 
         lwd=3)
  points(vObservations[vPassedIndices], vPassedIndices, pch=16, col="green3", 
         cex=3, lwd=3)
}
plotConsistencyTestResults('cL')
plotConsistencyTestResults('m')
plotConsistencyTestResults('s')