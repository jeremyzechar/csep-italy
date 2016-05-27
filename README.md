# csep-italy
Analysis of seismicity forecasts in the context of the CSEP Italy experiment

These are my notes based on what I did to roughly evaluate CSEP-Italy 5 yr forecasts for the final meeting of the REAKT project.

# For consistency tests
One of the things I do generically here is to find the bins where each event in the catalog falls, assuming that all forecasts have the same structure/order. I do that for the full forecasts, the magnitude-reduced forecasts, and the space-reduced forecasts. In the following, I list the scripts that must be run and note which test(s) is (are) dependent

M - magnitudeReduceAllModels.R to reduce all forecasts to their magnitude distribution

S - spaceReduceAllModels.R to reduce all forecasts to their spatial distribution

L, cL - collectIndicesForAllModels.R to find the bin where each target eqk fell (for the full forecasts)

M - collectIndicesForMagModels.R to find the bin where each target eqk fell (for the magnitude-reduced forecasts)

S - collectIndicesForSpaceModels.R to find the bin where each target eqk fell (for the space-reduced forecasts)

cL, M, S - simulateLogProbabilitiesForAllModels.R to simulate, for each individual forecast, many log-probabilities consistent w/ the forecast (full forecast for cL test, magnitude-reduced forecast for M test, space-reduced forecast for S test)


L - computeLTestForAllModels.R for each model, generate L test results: simulate probability distribution, calculate probability of observed catalog, calculate p-value, and save all of these things in a file-per-model

cL, M, S - computeOtherConsistencyTestsForAllModels.R for each model, generate cL, M, and S test results: calculate probability of observed catalog, calculate p-value by comparing w/ the pre-computed simulated probability distribution, count the number of observed events, and save all of these things in a file-per-model

All - tableConsistencyResults.R to make a table showing binary outcomes of all consistency tests (N-test is done on the fly)

# For comparison tests
calculateForecastRatesInOverlappingRegion.R to compute the forecast rate for every pair of forecasts where the forecasts are filtered to only include regions where both forecasts are unmasked, used to compute info gain

collectRatesForAllModels.R to find, for each individual forecast, the forecast rate where each target eqk fell
computeInfoGainForAllModels.R to compute info gain and uncertainty for every model relative to every other model

# Caveats
For the REAKT meeting I used nonstandard formats for the catalog and the forecasts. For example, the target catalog filtering is hardcoded in collectIndicesInTargetEqkBins_RDS.R and collectIndicesInTargetEqkBins.R and would need to be modified for another application. I also hardcoded the number of target events in simulateLogProbabilitiesForAllModels.R, that should be fixed.
