infoGainAndUncertainty <- function(vRatesA, vRatesB, fRateA, fRateB) {
  # For the two specified rate vectors and overall rates, compute the average
  # information gain and its uncertainty (which can be used to construct a 95%
  # confidence interval). Here, each vector reports the forecast rate in a bin
  # where a target eqk occurred, and the overall rates are the sum of the two
  # forecasts where both forecasts were unmasked. The 95% confidence interval is
  # formed as infoGain +/- uncertainty
  
  # So the total number of target eqks w/ which we can compare these two 
  # forecasts is the number of vector elements where neither forecast has an NA
  N <- length(which(!is.na(vRatesA) & !is.na(vRatesB)))
  
  infoGain <- (sum(log(vRatesA / vRatesB), na.rm=TRUE) - (fRateA - fRateB)) / N
  std <- sd(log(vRatesA / vRatesB), na.rm=TRUE)
  scale <- qt(0.975, N-1)
  uncertainty <- scale * std / sqrt(N)
  infoGainAndUncertainty <- c(infoGain, uncertainty)
}