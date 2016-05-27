indicesInTargetEqkBins_RDS <- function(sForecastFile, sCatalogFile, 
                                       minTargetMag = 4.95, maxTargetDepth = 30) {
  # For the specified forecast and the specified catalog file, store the index 
  # of each bin that hosts a target eqk.  To do this, filter the catalog to
  # have only target eqks (i.e., >= target magnitude and <= target depth),
  # then loop over each event in the catalog, find out the bin where it
  # occurred, and store the corresponding index. 
  
  # The forecast is a matrix w/ 10 columns: min/max lat/lon/depth/mag, forecast
  # 5-year rate, and a masking bit set to zero (ignore this bin) or one
  # The catalog file has 10 columns:
  # lon, lat, decimal year, month, day, magnitude, depth, hour, min, sec
  forecast <- readRDS(sForecastFile)
  
  catalog <- read.table(sCatalogFile, col.names = c('lon', 'lat', 'decyear',
                                                    'month', 'day', 'mag',
                                                    'depth', 'hour', 'min', 
                                                    'sec'))
  catalog <- catalog[which(catalog$mag >= minTargetMag), ]
  catalog <- catalog[which(catalog$depth <= maxTargetDepth), ]
  indices <- list()
  nEqks <- nrow(catalog)
  
  if (nEqks > 0){
    indices <- rep_len(NA, nEqks)
    
    lons <- catalog$lon
    lats <- catalog$lat
    mags <- catalog$mag
    
    for (j in 1: nEqks){
      lon <- lons[j]
      lat <- lats[j]
      mag <- mags[j]
      index <- which(forecast$minLon <= lon & forecast$maxLon > lon & 
                       forecast$minLat <= lat & forecast$maxLat > lat &
                       forecast$minMag <= mag & forecast$maxMag > mag)
      if (length(index) > 0){ # only set the rate if the eqk was in one of the bins
        indices[j] <- index
      }
    }
  }
  indices
}