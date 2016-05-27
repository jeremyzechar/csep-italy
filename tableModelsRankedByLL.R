# Make a table of the log-likelihood per eqk. Each row lists a model, the number
# of observed eqks in unmasked regions, and the log likelihood normalized by the 
# number of observed eqks in unmasked regions
sModelPath <- 'forecasts/'
sResultPath <- 'results/consistency/l/'
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
iModels <- length(vModels)
mResults <- matrix(nrow=iModels, ncol=2, dimnames=list(vModels, 
                                                       c('N', 'LLperN')))

vObservations <- rep(NA, iModels)
vIndicesOfTargetEvents <- readRDS('results/consistency/indices.RDS')

for (i in 1:iModels){
  model <- vModels[i]
  modelNickname <- vModelNicknames[i]
  sForecastFile <- paste0(sModelPath, model, '.italy.5yr.2010-01-01.txt')
  mForecast <- read.table(sForecastFile, col.names = c('minLat', 'maxLat', 
                                                       'minLon', 'maxLon',
                                                       'minDepth', 'maxDepth',
                                                       'minMag', 'maxMag',
                                                       'rate', 'mask'))
  mForecast$rate[which(mForecast$mask == 0)] <- NA
  vForecast <- mForecast$rate

  # Figure out how many target eqks occurred in unmasked bins for this forecast
  N <- sum(!is.na(vForecast[vIndicesOfTargetEvents]))    
  
  sResultFile <- paste0(sResultPath, 'probAndP_', modelNickname, '.rds')
  vResults <- readRDS(sResultFile)
  fLL <- vResults[1]
  
  mResults[i, 'LLperN'] <- fLL / N
  mResults[i, 'N'] <- N

}
print(mResults[order(-mResults[, 2]), ])