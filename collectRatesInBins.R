ratesInBins <- function(sForecastFile, sIndicesFile) {
  # For the specified forecast and the specified indices file, store the 
  # forecast rate in each bin. To do this, we 
  # loop over each event in the specified indices file and store the corresponding rate. 
  
  # The forecast is a matrix w/ 10 columns: min/max lat/lon/depth/mag, forecast
  # 5-year rate, and a masking bit set to zero (ignore this bin) or one
  # The catalog file has 8 columns:
  # origin time, lat, lon, depth, tempmag, magtype, source, mag
  
  forecast <- read.table(sForecastFile, col.names = c('minLat', 'maxLat', 
                                                      'minLon', 'maxLon',
                                                      'minDepth', 'maxDepth',
                                                      'minMag', 'maxMag',
                                                      'rate', 'mask'))
  # where the bin is masked, just set the rate to NA to make it clear
  forecast$rate[which(forecast$mask == 0)] <- NA
  
  catalog <- readRDS(sBinsFile)
  nEqks <- length(catalog)
  
  if (nEqks > 0){
    rates <- rep_len(NA, nEqks)
    
    for (j in 1: nEqks){
      index <-catalog[j]
      if (!is.na(index)){ # only set the rate if the eqk was in one of the bins
        rates[j] <- forecast$rate[index]  
      }
      
    }
    ratesInTargetEqkBins <- rates
  }
  
  ratesInTargetEqkBins
}