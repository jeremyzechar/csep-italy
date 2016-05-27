# Make a table of consistency results. Each row corresponds to a model, each 
# column is a consistency test, the entry in each cell is a pass or a fail
# depending on the p-value
sModelPath <- 'forecasts/'
vModels <- c('akinci-lombardi.HAZGRIDX', 'akinci.HAZFX_BPT', 'chan.HZA_TD',
             'chan.HZA_TI', 'console-murru-falcone.LTST', 'faenza.PHM_Grid', 
             'faenza.PHM_Zone', 'gulia-wiemer.ALM', 'gulia-wiemer.HALM', 
             'lombardi.DBM', 'meletti.MPS04', 'meletti.MPS04after', 'nanjo.RI', 
             'peruzza-pace-visini.LASSCI', 'schorlemmer-wiemer.ALM_IT', 
             'werner.HiResSmoSeis-m1', 'werner.HiResSmoSeis-m2', 
             'zechar.TripleS-CPTI', 'zechar.TripleS-CSI', 'zechar.TripleS-hybrid')
vModelNicknames <- c('akg', 'akb', 'chd', 'chi', 'con', 'fag', 'faz', 'gua', 
                     'guh', 'lom', 'mel', 'mea', 'nan', 'per', 'sch', 'wm1', 
                     'wm2', 'zep', 'zes','zeh')

sResultPath <- 'results/consistency/'

iModels <- length(vModels)
vTests <- c('n', 'l', 'cL', 'm', 's')
iTests <- length(vTests)
mResults <- matrix(nrow=iModels, ncol=iTests, dimnames=list(vModels, vTests))

for (i in 1:iModels){
  model <- vModels[i]
  modelNickname <- vModelNicknames[i]
  for (j in 1:iTests){
    test <- vTests[j]
    if (test == 'n'){
      sForecastFile <- paste0(sModelPath, model, '.italy.5yr.2010-01-01.txt')
      mForecast <- read.table(sForecastFile, col.names = c('minLat', 'maxLat', 
                                                           'minLon', 'maxLon',
                                                           'minDepth', 'maxDepth',
                                                           'minMag', 'maxMag',
                                                           'rate', 'mask'))
      fForecast <- sum(mForecast$rate, na.rm=TRUE)
      print(paste(modelNickname, fForecast))
      vIndices <- readRDS('results/consistency/indices.rds')
      nObs <- sum(!is.na(mForecast$rate[vIndices]))
      fDelta1 <- 1 - ppois(nObs - 1, fForecast)
      fDelta2 <- ppois(nObs, fForecast)
      if ((fDelta1 < 0.025) | (fDelta2 < 0.025)){
        mResults[i, j] <- '-'
      }
      else{
        mResults[i, j] <- '+'
      }
    }
    else{
      if (test == 'l'){
        sResultFile <- paste0(sResultPath, test, '/probAndP_', modelNickname, 
                              '.rds')
      }
      else{
        sResultFile <- paste0(sResultPath, test, '/catalogProbNAndP_', 
                              modelNickname, '.rds')
      }
      vResults <- readRDS(sResultFile)
      fP <- vResults[2]
      if (fP < 0.05){
        mResults[i, j] <- '-'
      }
      else{
        mResults[i, j] <- '+'
      }
    }
  }
}
print(mResults)