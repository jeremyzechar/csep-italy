source('shared/sim_log_dpois.R', chdir = T)
# simulate log probabilities for N (the number of events to simulate). This will
# be useful for cL/M/S tests, where the number of events to simulate depends on
# number of events in the catalog rather than the expected forecast rate (as in 
# the L-test). 
sSimProbsPath <- 'results/consistency/simulated log probabilities of forecasts/for cL, M, S tests/'
vSimProbsPath <- c(sSimProbsPath, paste0(sSimProbsPath, 'space-reduced/'), 
                   paste0(sSimProbsPath, 'magnitude-reduced/'))

sModelPath <- 'forecasts/'

vModelPaths<- c(sModelPath, paste0(sModelPath, 'space-reduced/'), 
                paste0(sModelPath, 'magnitude-reduced/'))

sResultsPath <- 'results/consistency/'

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

nNumberOfSimulations <- 1000 # number of simulations used to estimate
# each model's log probability distribution

vSimulatedProbabilities <- rep_len(NA, nNumberOfSimulations)
for (i in 1:iModels){ # loop over the models
  sModel <- vModels[i]
  sModelNickname <- vModelNicknames[i]

  # We need to find out how many target eqks occurred in unmasked bins for
  # this forecast, so we'll start by opening the full forecast and checking.
  sForecastFile <- paste0(sModelPath, sModel, '.italy.5yr.2010-01-01.txt')
  fullForecast <- read.table(sForecastFile, col.names = c('minLat', 'maxLat', 
                                                      'minLon', 'maxLon',
                                                      'minDepth', 'maxDepth',
                                                      'minMag', 'maxMag',
                                                      'rate', 'mask'))
  # where the bin is masked, just set the rate to NA
  fullForecast$rate[which(fullForecast$mask == 0)] <- NA
  vFullForecast <- fullForecast$rate
  
  # Figure out how many target eqks occurred in unmasked bins for this forecast
  vIndicesOfTargetEvents <- readRDS('results/consistency/indices.RDS')
  N <- sum(!is.na(vFullForecast[vIndicesOfTargetEvents]))    
  
  for (j in 1:length(vModelPaths)){ # do this for cL, M, and S tests
    modelPath <- vModelPaths[j]
    simProbsPath <- vSimProbsPath[j]
    
    vForecast <- vFullForecast
    
    # If we're simulating S- or M- log probabilities, we need to open the 
    # load the reduced forecast 
    if (modelPath != sModelPath){
      sForecastFile <- paste0(modelPath, sModel, '.rds')
      forecast <- readRDS(sForecastFile)

      # where the bin is masked, just set the rate to NA
      forecast$rate[which(forecast$mask == 0)] <- NA
      
      # We only need the rates vector to simulate log probabilities
      vForecast <- forecast$rate
      
    }
    
    # simulate the probability distribution of the model for the appropriate N  
    print(Sys.time())
    print(paste0('estimating probability distribution for ', sModelNickname, 
                 '_', N))    
    # normalize the forecast
    vForecast <- vForecast / sum(vForecast) * N
    for (k in 1:nNumberOfSimulations){
      vSimulatedProbabilities[k] <- sim_log_dpois(N, vForecast)
    }
    print(Sys.time())
    print(paste0('estimating probability distribution for ', sModelNickname, 
                 '_', N, '...done'))    
    vSimulatedProbabilities <- sort(vSimulatedProbabilities)
    
    simProbsFile <- paste0(simProbsPath, 'simProbs_', sModelNickname, '_', N,
                           '.rds')
    saveRDS(vSimulatedProbabilities, simProbsFile)
  }
}