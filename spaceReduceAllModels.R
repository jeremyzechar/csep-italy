# reduce each forecast to its space-only equivalent. This will be useful 
# for S tests. 

# To space-reduce, figure out the unique spatial cells, then for each one of 
# those, sum the rates over all magnitude bins.

sModelPath <- 'forecasts/'

sReducedModelPath <- paste0(sModelPath, 'space-reduced/')
vModels <- c('akinci-lombardi.HAZGRIDX', 'akinci.HAZFX_BPT', 'chan.HZA_TD',
             'chan.HZA_TI', 'console-murru-falcone.LTST', 'faenza.PHM_Grid', 
             'faenza.PHM_Zone', 'gulia-wiemer.ALM', 'gulia-wiemer.HALM', 
             'lombardi.DBM', 'meletti.MPS04', 'meletti.MPS04after', 'nanjo.RI', 
             'peruzza-pace-visini.LASSCI', 'schorlemmer-wiemer.ALM_IT', 
             'werner.HiResSmoSeis-m1', 'werner.HiResSmoSeis-m2', 
             'zechar.TripleS-CPTI', 'zechar.TripleS-CSI', 'zechar.TripleS-hybrid')

for (sModel in vModels){ # loop over the models
  print(paste0('space-reducing ', sModel, '...'))
  sForecastFile <- paste0(sModelPath, sModel, '.italy.5yr.2010-01-01.txt')
  forecast <- read.table(sForecastFile, col.names = c('minLat', 'maxLat', 
                                                      'minLon', 'maxLon',
                                                      'minDepth', 'maxDepth',
                                                      'minMag', 'maxMag',
                                                      'rate', 'mask'))
  # where the bin is masked, just set the rate to NA to make it clear
  forecast$rate[which(forecast$mask == 0)] <- NA
  vUniqueLatLons <- unique(forecast[, c("minLon", "maxLon", "minLat", "maxLat")])
  nUniqueCells <- nrow(vUniqueLatLons)
  minDept <- min(forecast$minDepth)
  maxDept <- max(forecast$maxDepth)
  minMag <- min(forecast$minMag)
  maxMag <- max(forecast$maxMag)
  spaceReducedForecast <- data.frame(minLon=vUniqueLatLons[, 1], 
                                     maxLon=vUniqueLatLons[, 2], 
                                     minLat=vUniqueLatLons[, 3], 
                                     maxLat=vUniqueLatLons[, 4], 
                                     minDepth=rep(minDept, nUniqueCells), 
                                     maxDepth=rep(maxDept, nUniqueCells), 
                                     minMag=rep(minMag, nUniqueCells),
                                     maxMag=rep(maxMag, nUniqueCells),
                                     rate=rep(NA, nUniqueCells), 
                                     mask=rep(0, nUniqueCells))
  for (i in 1:nUniqueCells){
    thisMinLon <- vUniqueLatLons[i, 1]
    thisMinLat <- vUniqueLatLons[i, 3]
    vCells <- which(forecast$minLon == thisMinLon & 
                      forecast$minLat == thisMinLat)
    spaceReducedForecast$rate[i] <- sum(forecast$rate[vCells], na.rm=TRUE)
    spaceReducedForecast$mask[i] <- min(forecast$mask[vCells])
  }

  sResult <- paste0(sReducedModelPath, sModel, '.rds')
  saveRDS(spaceReducedForecast, sResult)      
  print(paste0('space-reducing ', sModel, '...done'))
}