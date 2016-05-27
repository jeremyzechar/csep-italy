source('shared/computeInfoGainWithUncertainty.R')
# For every model, compute the info gain and uncertainty relative to each other model.
# For each model, we have an RDS 
# file; within this file is a data structure that has a vector of forecast rates
# for the catalog. To calculate the information gain, we also need
# to know the overall rate of each forecast in the bins where they both make a
# forecast; we have another RDS file with a dataframe containing this 
# information so we just need to look up the value when we loop over the models
# For each model we'll create a new RDS file w/ a data structure of info 
# gain and uncertainty for the catalog

sResultPath <- 'results/comparison/'
sRatesPath <-'results/comparison/rates in target eqk bins/'

vModels <- c('akg', 'akb', 'chd', 'chi', 'con', 'fag', 'faz', 'gua', 
             'guh', 'lom', 'mel', 'mea', 'nan', 'per', 'sch', 'wm1', 
             'wm2', 'zep', 'zes', 'zeh')
iModels <- length(vModels)

mRatesInOverlap <- readRDS(paste0(sResultPath, 'ratesInOverlap.rds'))
mInfoGain <- matrix(nrow=iModels, ncol=iModels, dimnames=list(vModels, vModels))
mUncertainty <- matrix(nrow=iModels, ncol=iModels, dimnames=list(vModels, vModels))

for (i in 1:(iModels-1)){
  sModel <- vModels[i]
  for (j in (i + 1):iModels){
    sRefModel = vModels[j]   
    fRefModelRate <- mRatesInOverlap[sRefModel, sModel] # ref rates
    fModelRate <- mRatesInOverlap[sModel, sRefModel] # rate per
    
  
    rates <- readRDS(paste0(sRatesPath, 'rates_', sModel, '.rds'))
    refRates <- readRDS(paste0(sRatesPath, 'rates_', sRefModel, '.rds'))
  
    vRates <- rates
    vRefRates <- refRates
    if (!is.null(vRates) & !is.null(vRefRates)){
      result <- infoGainAndUncertainty(vRefRates, vRates, fRefModelRate, 
                                       fModelRate)
      mInfoGain[i, j] <- result[1]
      mInfoGain[j, i] <- -result[1]
      mUncertainty[i, j] <- result[2]
      mUncertainty[j, i] <- result[2]
    }
  }
  resultFile <- paste0(sResultPath, 'info_gains.rds')
  saveRDS(mInfoGain, file=resultFile)
  resultFile <- paste0(sResultPath, 'info_gain_uncertainty.rds')
  saveRDS(mUncertainty, file=resultFile)
   
}