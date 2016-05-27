source('collectRatesInBins.R')
# for all models, pick out and save the rates in the bins where
# target eqks occurred for all events in the catalog, where we found the 
# bins in advance

# I should get the rates back from the ratesInBins function
# and save them using saveRDS in a file w/ naming format 
# rates_{model}.rds

sIndicesPath <- 'results/consistency/'
sRatesPath <- 'results/comparison/rates in target eqk bins/'

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

for (i in 1:iModels){ # loop over the models
  sModel <- vModels[i]
  sModelNickname <- vModelNicknames[i]
  sForecastFile <- paste0(sModelPath, sModel, '.italy.5yr.2010-01-01.txt')

  sBinsFile <- paste0(sIndicesPath, 'indices.rds')
  print(Sys.time())
  print(paste0('collecting rates for ', sModelNickname, '...'))
  rates <- ratesInBins(sForecastFile, sBinsFile)
  print(Sys.time())
  print(paste0('collecting rates for ', sModelNickname, '...done'))      
  resultFile <- paste0(sRatesPath, 'rates_', sModelNickname, '.rds')
  saveRDS(rates, file=resultFile)
}