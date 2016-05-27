SimConsistentCatalog <- function(n, lambda){
  # Simulate a vector of integer quantiles x given the vector of non-negative 
  #   means lambda, normalized such that their sum is unity. the integer 
  #   quantiles should be simulated in a way that is consistent with lambda. 
  #   n is the total number of events to simulate
  
  nElements <- length(lambda)
  x <- rep_len(0, nElements)
  
  lambda[which(is.na(lambda))] <- 0
  # construct a vector that is the cumulative sum of the normalized lambda, 
  #   use this to determine where each simulated event should be placed
  vLambdaCumSum <- cumsum(lambda / sum(lambda, na.rm=TRUE))
  
  # generate random numbers to place events
  vRands <- runif(n)
  
  vIndices <- vector()
  # map the random numbers to the quantiles
  for (vRand in vRands){
    index <- which.max(vLambdaCumSum > vRand)
    x[index] <- x[index] + 1
    vIndices <- c(vIndices, index)
  }
  
  return(vIndices)
}