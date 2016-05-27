# For the consistency tests, I need to calculate the log probability of the
# catalog conditional on each model. That's the same regardless of whether it's
# a cL, L, M, or S test. Then, this log probability should be compared w/ the 
# simulations of log probability for each model (i.e., those simulations that 
# are used to estimate the log probability distribution of each model). The L
# test is different from the others b/c in that case, the number of events to 
# simulate is determined by the forecast. In all other cases, the number of 
# events to simulate depends on the number of events in the observed 
# catalog. So I've treated L separately. But what I'm doing here
# is running through the catalog and getting the 'obs log prob' piece 
# needed for cL/M/S tests. While we're here and getting that number, I might as
# well compare it to the corresponding simulated distribution (I precomputed 
# those, so I just need to open the appropriate 
# file), thereby getting the p-value, and just as in the L-test, I'll save the 
# probability of the catalog and the p-value. In addition, I'll save N.
# The way I set things up, getting N is a little trickier than it might seem.
# The foolproof way of doing it is this: for the catalog, look at the full
# forecast and check the forecast values at the indices where the catalog
# events occur, the number of non-NA forecast values is N.
source('shared/sim_log_dpois.R', chdir = T)

sSimProbsPath <- 'results/consistency/simulated log probabilities of forecasts/for cL, M, S tests/'
sResultPath <- 'results/consistency/'
sIndicesPath <- 'results/consistency/'
sModelPath <- 'forecasts/'

vTestPaths <- c('cL/', 's/', 'm/')
vSimProbTypes <- c('', 'space-reduced/', 'magnitude-reduced/')
vIndexSuffixes <- c('', 'space_', 'mag_')

# vTestPaths <- c('cL/')
# vSimProbTypes <- c('')
# vIndexSuffixes <- c('')

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
  
  for (m in 1:length(vTestPaths)){
    sTestPath <- vTestPaths[m]
    sSimProbType <- vSimProbTypes[m]
    sIndexSuffix <- vIndexSuffixes[m]
    if (sTestPath == 'cL/'){
      vForecast <- vFullForecast
    }
    else{
      sForecastFile <- paste0(sModelPath, sSimProbType, sModel, '.rds')
      forecast <- readRDS(sForecastFile)
      forecast$rate[which(forecast$mask == 0)] <- NA
      vForecast <- forecast$rate
    }

    nBins <- length(vForecast)

    # compute the probability of the catalog and estimate a 
    #       corresponding p-value. To get the observation vector, simply load 
    #       the indices file; it tells us where the events occurred, so just
    #       start w/ an empty vector and add an event in each bin mentioned in
    #       the indices file
    if (sTestPath == 'cL/'){
      sIndicesFile <- paste0(sIndicesPath, 'indices.rds')
    }
    if (sTestPath == 'm/'){
      sIndicesFile <- paste0(sIndicesPath, 'indices_mag.rds')
    }
    if (sTestPath == 's/'){
      sIndicesFile <- paste0(sIndicesPath, 'indices_space.rds')
    }
    
    indices <- readRDS(sIndicesFile)
    
    # generate an observation vector for the observed catalog
    #     compute the log probability of this observation vector and the p-value
    #     (i.e., where it falls relative to the simulated probabilities)
    print(Sys.time())
    print(paste0('calculating probability of catalog for ', sModel))    
    vIndicesOfInterest <- indices
    vObs <- rep_len(0, nBins)
      
    # generate an observation vector from the catalog indices
    for (index in vIndicesOfInterest){
      if (!is.na(index)){
        vObs[index] <- vObs[index] + 1
      }
    }

    # scale the forecast to have the same total expectation as N
    vForecast <- vForecast / sum(vForecast, na.rm=TRUE) # resulting forecast should sum to 1
    vForecast <- vForecast * N

    # calculate the log probability of this observation vector
    fCatalogProbability <- log_dpois_sparse(vObs, vForecast)
    
    sSimProbsFile <- paste0(sSimProbsPath, sSimProbType, 'simProbs_', 
                            sModelNickname, '_', N, '.rds')
    vSimulatedProbabilities <- sort(readRDS(sSimProbsFile))
    nNumberOfSimulations <- length(vSimulatedProbabilities)
    
    # find the p-value of this log-probability
    fCatalogPValue <- length(which(fCatalogProbability >= 
                                     vSimulatedProbabilities)) /
      nNumberOfSimulations

    print(Sys.time())
    print(paste0('calculating probability of catalog for ', sModel, '...done'))    
    
    # I'll save the probability of the catalog, the 
    #       corresponding p-value, and the value of N
    sResultFile <- paste0(sResultPath, sTestPath, 'catalogProbNAndP_', 
                          sModelNickname, '.rds')
    saveRDS(cbind(fCatalogProbability, fCatalogPValue, N), sResultFile)
  }  
}