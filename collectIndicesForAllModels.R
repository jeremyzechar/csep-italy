source('collectIndicesInTargetEqkBins.R')
# for the observed catalog, use one model to pick out the indices of the bins 
# where target eqks occurred 

# Get the indices back from the indicesInTargetEqkBins 
# function and save them using saveRDS in a file named
# indices.rds

sModelPath <- 'forecasts/'
sCatalogPath <- 'data/'
sResultPath <- 'results/consistency/'
sModel <- 'lombardi.DBM'
sForecastFile <- paste0(sModelPath, sModel, '.italy.5yr.2010-01-01.txt')
sCatalogFile <- paste0(sCatalogPath, 
                       'Italian bulletin 2009.08.01 to 2015.07.31 M5+ from Matteo.txt')
indices <- indicesInTargetEqkBins(sForecastFile, sCatalogFile)
resultFile <- paste0(sResultPath, 'indices.rds')
saveRDS(indices, file=resultFile)