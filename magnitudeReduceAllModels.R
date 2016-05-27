# reduce each forecast to its magnitude-only equivalent, this will be 
# useful for M tests. 

# To magnitude-reduce, figure out the unique magnitude bins, then for each one
# of those, sum the rates over all spatial cells where the cells are unmasked.

sModelPath <- 'forecasts/'

sReducedModelPath <- paste0(sModelPath, 'magnitude-reduced/')
vModels <- c('akinci-lombardi.HAZGRIDX', 'akinci.HAZFX_BPT', 'chan.HZA_TD', 
             'chan.HZA_TI', 'console-murru-falcone.LTST', 'faenza.PHM_Grid',
             'faenza.PHM_Zone', 'gulia-wiemer.ALM', 'gulia-wiemer.HALM', 
             'lombardi.DBM', 'meletti.MPS04', 'meletti.MPS04after', 'nanjo.RI', 
             'peruzza-pace-visini.LASSCI', 'schorlemmer-wiemer.ALM_IT', 
             'werner.HiResSmoSeis-m1', 'werner.HiResSmoSeis-m2', 
             'zechar.TripleS-CPTI', 'zechar.TripleS-CSI', 'zechar.TripleS-hybrid')

for (sModel in vModels){ # loop over the models
  print(paste0('mag-reducing ', sModel, '...'))
  sForecastFile <- paste0(sModelPath, sModel, '.italy.5yr.2010-01-01.txt')
  forecast <- read.table(sForecastFile, col.names = c('minLat', 'maxLat', 
                                                      'minLon', 'maxLon',
                                                      'minDepth', 'maxDepth',
                                                      'minMag', 'maxMag',
                                                      'rate', 'mask'))
  # where the bin is masked, just set the rate to NA to make it clear
  forecast$rate[which(forecast$mask == 0)] <- NA
  vUniqueMags <- unique(forecast[, c("minMag", "maxMag")])
  nUniqueMags <- nrow(vUniqueMags)
  minLati <- min(forecast$minLat)
  maxLati <- max(forecast$maxLat)
  minLong <- min(forecast$minLon)
  maxLong <- max(forecast$maxLon)
  minDept <- min(forecast$minDepth)
  maxDept <- max(forecast$maxDepth)
  magReducedForecast <- data.frame(minLon=rep(minLong, nUniqueMags), 
                                   maxLon=rep(maxLong, nUniqueMags), 
                                   minLat=rep(minLati, nUniqueMags), 
                                   maxLat=rep(maxLati, nUniqueMags), 
                                   minDepth=rep(minDept, nUniqueMags), 
                                   maxDepth=rep(maxDept, nUniqueMags), 
                                   minMag=vUniqueMags[, 1],
                                   maxMag=vUniqueMags[, 2],
                                   rate=rep(NA, nUniqueMags), 
                                   mask=rep(1, nUniqueMags))
  for (i in 1:nUniqueMags){
    thisMinMag <- vUniqueMags[i, 1]
    magReducedForecast$rate[i] <- sum(
      forecast$rate[which(forecast$minMag == thisMinMag)], na.rm=TRUE)
  }

  sResult <- paste0(sReducedModelPath, sModel, '.rds')
  saveRDS(magReducedForecast, sResult)      
  print(paste0('mag-reducing ', sModel, '...done'))
}