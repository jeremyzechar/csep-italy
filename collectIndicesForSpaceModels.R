source('collectIndicesInTargetEqkBins_RDS.R')
# for the catalog, use one space-reduced RELM model to 
# pick out and save the indices of the bins where target eqks occurred 

sCatalogPath <- 'data/'
sResultPath <- 'results/consistency/'

sModelPath <- 'forecasts/space-reduced/'
sModel <- 'akinci.HAZFX_BPT'
sForecastFile <- paste0(sModelPath, sModel, '.rds')

sCatalogFile <- paste0(sCatalogPath, 
                       'Italian bulletin 2009.08.01 to 2015.07.31 M5+ from Matteo.txt')
print(Sys.time())
print(paste0('collecting indices for space models...'))
indices <- indicesInTargetEqkBins_RDS(sForecastFile, sCatalogFile)
print(Sys.time())
print(paste0('collecting indices for space models...done'))
resultFile <- paste0(sResultPath, 'indices_space.rds')
saveRDS(indices, file=resultFile)
