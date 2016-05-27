# Explore S-test failures: for each model, make a boxplot of the forecast rates
# and make a scatterplot showing the rate in each target eqk bin

sModelPath <- 'forecasts/space-reduced/'
vModels <- c('akinci-lombardi.HAZGRIDX', 'akinci.HAZFX_BPT', 'chan.HZA_TD',
             'chan.HZA_TI', 'console-murru-falcone.LTST', 'faenza.PHM_Grid', 
             'faenza.PHM_Zone', 'gulia-wiemer.ALM', 'gulia-wiemer.HALM', 
             'lombardi.DBM', 'meletti.MPS04', 'meletti.MPS04after', 'nanjo.RI', 
             'peruzza-pace-visini.LASSCI', 'schorlemmer-wiemer.ALM_IT', 
             'werner.HiResSmoSeis-m1', 'werner.HiResSmoSeis-m2', 
             'zechar.TripleS-CPTI', 'zechar.TripleS-CSI', 'zechar.TripleS-hybrid')
vModelNicknames <- c('HAZGRIDX', 'HAZFX_BPT ', 'HZA_TD', 'HZA_TI', 'LTST', 
                     'PHM_Grid', 'PHM_Zone', 'ALM', 'HALM', 'DBM', 'MPS04', 
                     'MPS04a', 'RI', 'LASSCI', 'ALM.IT', 'HiResSmoSeis-m1', 
                     'HiResSmoSeis-m2', 'TripleS-CPTI', 'TripleS-CSI',
                     'TripleS-Hybrid')
iModels <- length(vModels)

# put together what is needed to make a boxplot of spatial forecast rates: a 
# data frame where the first column is the forecast rate and the second column
# is the nickname of the model. Before even opening a model, we can put together
# the vector that will be the second column.
nSpatialCells <- 8993 # got this by putting a breakpoint at l. 30 of spaceReduceAllModels.R
vModelLabels <- rep(vModelNicknames, each=nSpatialCells)
vModelRates <- NULL # make a null vector that will be used to store the rates

# put together what is needed to make a line plot of the forecast rates in each
# target eqk bin: a matrix where each column holds the vector of rates in the 
# target eqk bins
vIndicesOfTargetEvents <- readRDS('results/consistency/indices_space.rds')
nIndices <- length(vIndicesOfTargetEvents)
mTargetBinRates <- matrix(data = NA, nrow = nIndices, ncol = iModels)
vTargetModelLabels <- rep(vModelNicknames, each=nIndices)
vTargetModelRates <- NULL # make a null vector that will be used to store the rates


for (i in 1:iModels){
  model <- vModels[i]
  sForecastFile <- paste0(sModelPath, model, '.rds')
  mForecast <- readRDS(sForecastFile)
  mForecast$rate[which(mForecast$mask == 0)] <- NA
  vForecast <- mForecast$rate
  vModelRates <- c(vModelRates, vForecast)
  mTargetBinRates[, i] <- vForecast[vIndicesOfTargetEvents]
  vTargetModelRates <- c(vTargetModelRates, vForecast[vIndicesOfTargetEvents])

}
dfRates <- data.frame(rates=vModelRates, model=vModelLabels)
boxplot(rates~model, data=dfRates, col="lightgray")
matplot(mTargetBinRates, type = c("b"),pch=1,col = 1:iModels)
legend("topleft", legend = vModelNicknames, col=1:iModels, pch=1)

dfTargetRates <- data.frame(rates=vTargetModelRates, model=vTargetModelLabels)
ggplot(data = dfTargetRates, aes(x=rep(1:nIndices, iModels), y=rates)) + 
  geom_line(aes(colour=model))


# S-test failures seem to be caused by events 7-11 all occurring in a single spatial cell
# 
# "HAZGRIDX"        "LTST"            "PHM_Grid"        "PHM_Zone"        "ALM"            
# "HALM"            "ALM.IT"          "HiResSmoSeis-m1" "TripleS-CSI"
# 
# all have rate smaller than 1e-3
vModelNicknames[mTargetBinRates[7, ] < 1e-3]
# Almost all models w/ rate smaller than 1.8e-3 fail the S-test (although some
# models have a smaller rate but still pass)
vModelNicknames[mTargetBinRates[7, ] < 1.8e-3]
# HZA_TD passes S-test (barely, p=0.062) but has a smaller rate. And MPS04 fails
# but has a rate higher than 1.8e-3: in particular, 2.06e-3 
vModelNicknames[mTargetBinRates[7, ] < 2.1e-3]

# Find out which eqks are events 7-11
sCatalogFile <- "data/Italian bulletin 2009.08.01 to 2015.07.31 M5+ from Matteo.txt"
catalog <- read.table(sCatalogFile, col.names = c('lon', 'lat', 'decyear',
                                                  'month', 'day', 'mag',
                                                  'depth', 'hour', 'min', 
                                                  'sec'))
catalog[7:11, ]
