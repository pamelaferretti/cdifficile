################################################################################
#Toolbox 16S
#
#Convenience functions to calculate alpha diversities from count tables
#
#2017-09-15
#sebastian.schmidt@embl.de
################################################################################

################################################################################
################################################################################
#Shannon entropy
shannon <- function(tax.counts) {
  #Remove taxa that have not been observed (freq == 0)
  freq <- tax.counts[tax.counts > 0];
  s.obs <- length(freq);
  #If no non-zero taxa have been observed, return H = 0 with a warning
  if (s.obs == 0) {warning("No non-zero taxa left in taxa table!"); return(0)}
  n.tot <- sum(freq);
  n.rel.tmp <- freq / n.tot; n.rel <- n.rel.tmp[n.rel.tmp > 0];
  s.shannon <- -(sum(n.rel * log(n.rel)));
  s.shannon
}

#Hill diversity (classical)
#=> on an entire count table (taxa as rows, samples as columns) of absolute (!) counts
D.hill <- function(count.table, q.H=1) {
  #Handle special case of q == 1
  if (q.H == 1) {
    #warning("Hill diversity is not defined for q = 1. Calculating the limit case of D = exp(H), the exponential of the Shannon entropy, instead.");
    return(apply(count.table, 2, function(tax.counts) {exp(shannon(tax.counts))}))
  }
  
  #Handle special case of q == 0
  #=> output richness only
  if (q.H == 0) {
    return(colSums(count.table > 0))
  }
  
  #Get relative abundances (normalize by colSums)
  ct.rel <- t(t(count.table) / colSums(count.table))
  
  #Raise all relative abundances to exponent q
  q.ct <- as.matrix(ct.rel) ^ q.H;
  colSums(q.ct) ^ (1/(1-q.H))
}
################################################################################
################################################################################