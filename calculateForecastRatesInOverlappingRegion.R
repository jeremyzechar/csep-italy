rateInOverlap <- function(sForecastFileA, sForecastFileB) {
  # For the specified forecasts, figure out the total unmasked forecast rate: 
  # find the bins where neither forecast is masked and sum over these bins,
  # returning a 2-element vector containing the sum for each forecast

  rateInOverlap <- rep_len(NA, 2)
  
  # Each forecast is a matrix w/ 10 columns: min/max lon/lat/depth/mag, forecast
  # 5-year rate, and a masking bit set to zero (indicating that one should 
  # ignore this bin) or one
  forecastA <- read.table(sForecastFileA, col.names = c('minLat', 'maxLat', 
                                                        'minLon', 'maxLon',
                                                        'minDepth', 'maxDepth',
                                                        'minMag', 'maxMag',
                                                        'rate', 'mask'))
  forecastB <- read.table(sForecastFileB, col.names = c('minLat', 'maxLat', 
                                                        'minLon', 'maxLon',
                                                        'minDepth', 'maxDepth',
                                                        'minMag', 'maxMag',
                                                        'rate', 'mask'))
  
  # where the bin in either forecasts is masked, set the rate in both forecasts
  # to NA
  forecastA$rate[which(forecastA$mask == 0 | forecastB$mask == 0)] <- NA
  forecastB$rate[which(forecastA$mask == 0 | forecastB$mask == 0)] <- NA
  
  # now compute the sum 
  rateInOverlap[1] <- sum(forecastA$rate, na.rm=TRUE)
  rateInOverlap[2] <- sum(forecastB$rate, na.rm=TRUE)
  rateInOverlap
}

# Using the function above, generate and save a matrix that contains the overall
# forecast rate for each RELM mainshock forecast when compared w/ another 
# forecasts, accounting for the masking of both forecasts being compared.
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
iModels <- length(vModels)

mRatesInOverlap <- matrix(nrow=iModels, ncol=iModels, 
                          dimnames=list(vModelNicknames, vModelNicknames))
for (i in 1:(iModels-1)){
  sModel1 <- paste0(sModelPath, vModels[i], '.italy.5yr.2010-01-01.txt')
  for (j in (i+1):iModels){
    sModel2 <- paste0(sModelPath, vModels[j], '.italy.5yr.2010-01-01.txt')
    vRatesInOverlap <- rateInOverlap(sModel1, sModel2)
    mRatesInOverlap[i, j] <- vRatesInOverlap[1]
    mRatesInOverlap[j, i] <- vRatesInOverlap[2]
  }
}
resultFile <- 'results/comparison/ratesInOverlap.rds'
saveRDS(mRatesInOverlap, file=resultFile)