source('log_dpois_sparse.R')
sim_log_dpois <- function(n, lambda){
  # Simulate a log of the joint probability of a vector of simulated
  #   integer quantiles x given the vector of non-negative means lambda, 
  #   normalized such that their sum is unity. the integer quantiles should be 
  #   simulated in a way that is consistent with lambda. n is the total number 
  #   of events to simulate
  
  nElements <- length(lambda)
  x <- rep_len(0, nElements)
  lambda[which(is.na(lambda))] <- 0
  
  # construct a vector that is the cumulative sum of the normalized lambda, 
  #   use this to determine where each simulated event should be placed
  vLambdaCumSum <- cumsum(lambda / sum(lambda, na.rm=TRUE))
  
  # generate random numbers to place events
  vRands <- runif(n)
  
  # map the random numbers to the quantiles
  for (vRand in vRands){
    index <- which.max(vLambdaCumSum > vRand)
    x[index] <- x[index] + 1
  }
  
  sim_log_dpois <- log_dpois_sparse(x, lambda)  
}
# print(sim_log_dpois(10, vForecast))