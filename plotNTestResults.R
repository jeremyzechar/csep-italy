library(Hmisc)
# Make a plot of N-test results as in RELM I: First-order results. For each 
# model, plot the 95% acceptance region as horizontal error bars abt the 
# forecast expectation. Plot the observed number of eqks in unmasked regions as
# a circle. If the circle falls outside the acceptance region, plot it in red,
# otherwise green.
sModelPath <- 'forecasts/'
vModels <- c('akinci-lombardi.HAZGRIDX', 'akinci.HAZFX_BPT', 'chan.HZA_TD',
             'chan.HZA_TI', 'console-murru-falcone.LTST', 'faenza.PHM_Grid', 
             'faenza.PHM_Zone', 'gulia-wiemer.ALM', 'gulia-wiemer.HALM', 
             'lombardi.DBM', 'meletti.MPS04', 'meletti.MPS04after', 'nanjo.RI', 
             'peruzza-pace-visini.LASSCI', 'schorlemmer-wiemer.ALM_IT', 
             'werner.HiResSmoSeis-m1', 'werner.HiResSmoSeis-m2', 
             'zechar.TripleS-CPTI', 'zechar.TripleS-CSI', 'zechar.TripleS-hybrid')
# vModelNicknames <- c('akg', 'akb', 'chd', 'chi', 'con', 'fag', 'faz', 'gua', 
#                      'guh', 'lom', 'mel', 'mea', 'nan', 'per', 'sch', 'wm1', 
#                      'wm2', 'zep', 'zes','zeh')
vModelNicknames <- c('HAZGRIDX', 'HAZFX_BPT ', 'HZA_TD', 'HZA_TI', 'LTST', 
                     'PHM_Grid', 'PHM_Zone', 'ALM', 'HALM', 'DBM', 'MPS04', 
                     'MPS04a', 'RI', 'LASSCI', 'ALM.IT', 'HiResSmoSeis-m1', 
                     'HiResSmoSeis-m2', 'TripleS-CPTI', 'TripleS-CSI',
                     'TripleS-Hybrid')

vModels <- rev(vModels) # so they end up in alphabetical order in the plot
vModelNicknames <- rev(vModelNicknames)

sResultPath <- 'results/consistency/'

iModels <- length(vModels)
vExpectations <- rep(NA, iModels)
vObservations <- rep(NA, iModels)
vIndicesOfTargetEvents <- readRDS('results/consistency/indices.RDS')

for (i in 1:iModels){
  model <- vModels[i]
  sForecastFile <- paste0(sModelPath, model, '.italy.5yr.2010-01-01.txt')
  mForecast <- read.table(sForecastFile, col.names = c('minLat', 'maxLat', 
                                                       'minLon', 'maxLon',
                                                       'minDepth', 'maxDepth',
                                                       'minMag', 'maxMag',
                                                       'rate', 'mask'))
  mForecast$rate[which(mForecast$mask == 0)] <- NA
  vForecast <- mForecast$rate

  fForecast <- sum(vForecast, na.rm=TRUE)
  vExpectations[i] <- fForecast
  
  # Figure out how many target eqks occurred in unmasked bins for this forecast
  vObservations[i] <- sum(!is.na(vForecast[vIndicesOfTargetEvents]))    
  
}

vLowers <- qpois(0.025, vExpectations)
vUppers <- qpois(0.975, vExpectations)

errbar(vModelNicknames, vExpectations, vLowers, vUppers, pch=3)

title("N-Test", xlab = "Earthquakes")
# find and denote the models that fail the test
vFailedIndices <- which(vObservations < vLowers | vObservations > vUppers)
vPassedIndices <- which(vObservations >= vLowers & vObservations <= vUppers)
points(vObservations[vFailedIndices], vFailedIndices, pch=1, col="red", cex=3, 
       lwd=3)
points(vObservations[vPassedIndices], vPassedIndices, pch=16, col="green3", 
       cex=3, lwd=3)

