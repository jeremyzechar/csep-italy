source('shared/sim_log_dpois.R', chdir = T)

# For every model, efficiently conduct an L test. 
# To do this, we loop over the models, and for each model, we simulate the 
# probability distribution of the model and thereby derive the desired rejection
# region. Then we compute the probability of the catalog and estimate a
# corresponding p-value. I'll save the simulated probabilities, the probability
# of the catalog, and the corresponding p-value.

sSimProbsPath <- 'results/consistency/simulated log probabilities of forecasts/'
sResultPath <-  'results/consistency/l/'
sIndicesPath <- 'results/consistency/'
sModelPath <- 'forecasts/'
nNumberOfSimulations <- 1000 # number of simulations used to estimate
                              # each model's probability distribution

vModels <- c('akinci-lombardi.HAZGRIDX', 'akinci.HAZFX_BPT', 'chan.HZA_TD', 
             'chan.HZA_TI', 'console-murru-falcone.LTST', 'faenza.PHM_Grid',
             'faenza.PHM_Zone', 'gulia-wiemer.ALM', 'gulia-wiemer.HALM', 
             'lombardi.DBM', 'meletti.MPS04', 'meletti.MPS04after', 'nanjo.RI', 
             'peruzza-pace-visini.LASSCI', 'schorlemmer-wiemer.ALM_IT', 
             'werner.HiResSmoSeis-m1', 'werner.HiResSmoSeis-m2', 
             'zechar.TripleS-CPTI', 'zechar.TripleS-CSI', 'zechar.TripleS-hybrid')
vModelNicknames <- c('akg', 'akb', 'chd', 'chi', 'con', 'fag', 'faz', 'gua', 
                     'guh', 'lom', 'mel', 'mea', 'nan', 'per', 'sch', 'wm1', 
                     'wm2', 'zep', 'zes', 'zeh')
iModels <- length(vModels)

vSimulatedProbabilities <- rep_len(NA, nNumberOfSimulations)
for (i in 1:iModels){ # loop over the models
  sModel <- vModels[i]
  sModelNickname <- vModelNicknames[i]
  sForecastFile <- paste0(sModelPath, sModel, '.italy.5yr.2010-01-01.txt')
  forecast <- read.table(sForecastFile, col.names = c('minLat', 'maxLat', 
                                                      'minLon', 'maxLon',
                                                      'minDepth', 'maxDepth',
                                                      'minMag', 'maxMag',
                                                      'rate', 'mask'))
  # where the bin is masked, just set the rate to NA to make it clear
  forecast$rate[which(forecast$mask == 0)] <- NA
  nBins <- nrow(forecast)
  vForecast <- forecast$rate
      
  # simulate the probability distribution of the model
  # The number of events in each simulation can vary based on the forecast
  #     expectation, so we need to know the expected value
  fExpectedEqks <- sum(vForecast, na.rm=TRUE)
  vNumberOfEventsToSimulate <- rpois(nNumberOfSimulations, fExpectedEqks)
  print(Sys.time())
  print(paste0('estimating probability distribution for ', sModel))    
  for (k in 1:nNumberOfSimulations){
    if (vNumberOfEventsToSimulate[k] > 0){
      vSimulatedProbabilities[k] <- sim_log_dpois(
        vNumberOfEventsToSimulate[k], vForecast)
    }
    else{
      vSimulatedProbabilities[k] <- -fExpectedEqks
    }
  }
  print(Sys.time())
  print(paste0('estimating probability distribution for ', sModel, '...done'))    
  vSimulatedProbabilities <- sort(vSimulatedProbabilities)

  # compute the probability of the catalog and estimate a 
  #     corresponding p-value. To get the observation vector, simply look at 
  #     the values in the indices file; each entry tells us where the events 
  #     occurred, so just start w/ an empty vector and add an event in each 
  #     bin mentioned in the indices file
  sIndicesFile <- paste0(sIndicesPath, 'indices.rds')
  indices <- readRDS(sIndicesFile)      
      
  # read the indices file, generate an observation vector, 
  #     compute the log probability of this observation vector and the p-value
  #     (i.e., where it falls relative to the simulated probabilities)
  print(Sys.time())
  print(paste0('calculating probabilities of catalog for ', sModel))    
  vObs <- rep_len(0, nBins)
    
  # generate an observation vector
  for (index in indices){
    vObs[index] <- vObs[index] + 1
  }
  
  # calculate the log probability of this observation vector
  fCatalogProbability <- log_dpois_sparse(vObs, vForecast)
  
  # find the p-value of this log-probability
  fCatalogPValue <- length(which(fCatalogProbability >= vSimulatedProbabilities)) /
    nNumberOfSimulations

  print(Sys.time())
  print(paste0('calculating probability of catalog for ', sModel, '...done'))    
  
  # I'll save the simulated probabilities, the probability of the 
  #     catalog, and the corresponding p-value.    
  sResultFile <- paste0(sSimProbsPath, 'simProbs_', sModelNickname, '.rds')
  saveRDS(vSimulatedProbabilities, sResultFile)
  sResultFile <- paste0(sResultPath, 'probAndP_', sModelNickname, '.rds')
  saveRDS(cbind(fCatalogProbability, fCatalogPValue), sResultFile)
}