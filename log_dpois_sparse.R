log_dpois_sparse <- function(x, lambda){
  # Compute the log of the joint probability of the specified non-negative
  #   integer quantiles x given the vector of non-negative means lambda, and do
  #   so in a way that is efficient for sparse vector x. The idea is that we
  #   can group all the elements with lambda[] = 0
  
  # find the indices where the observation is nonzero, these are the only
  # ones where we need to call dpois
  vIndicesOfNonzero <- which(x > 0)
  
  # if the observation is everywhere nonzero, the log probability is just the
  #   negative of the sum of all expectations
  if (length(vIndicesOfNonzero) == 0){
    fLog_dpois <- -sum(lambda, na.rm=TRUE)
  }
  else{
    # When the observation is zero, the log probability is just the negative
    #   expectation, so we can sum the expectations there
    fLambdaWhereZero <- sum(lambda[-vIndicesOfNonzero], na.rm=TRUE)
    
    # To get the total log probability, we subtract the log probability above 
    #     from the log probability of all those elements where the observation 
    #     is nonzero
    fLog_dpois <- sum(log(dpois(x[vIndicesOfNonzero], 
                                lambda[vIndicesOfNonzero])), na.rm=TRUE) - 
      fLambdaWhereZero
  }
  fLog_dpois
}