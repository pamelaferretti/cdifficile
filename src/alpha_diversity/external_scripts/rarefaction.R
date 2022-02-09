################################################################################
#Toolbox 16S
#
#Convenience functions to perform rarefaction analyses
#
#2017-09-15
#sebastian.schmidt@embl.de
################################################################################

################################################################################
################################################################################
#Function: rarefaction_analysis
#
#Input: count table, (relative) rarefaction steps, iterations per step (optional), Hill q to perform
################################################################################
################################################################################
source("https://raw.githubusercontent.com/defleury/Toolbox_16S/master/R/function.alpha_diversity.R")
rarefaction <- function(count.table, steps=c(seq(0.01, 0.09, by=0.01), seq(0.1, 0.9, by=0.1), 0.99), iterations=100) {
  #Get current sample sizes
  size.sample <- colSums(count.table)
  #Get overall taxa count
  n.tax <- nrow(count.table)
  
  #Get relative counts
  count.table <- as.matrix(count.table)
  ct.rel <- as.matrix(t(t(count.table) / size.sample))
  
  #Preallocate results collector data.frame
  #=> add trivial rarefaction step at 0 counts
  results.rarefy <- data.frame(
    sample.name = colnames(count.table),
    N.seq = 0,
    N.obs = 0
  )
  
  #Iterate through rarefaction steps and perform rarefactions
  for (step in steps) {
    curr.sizes <- ceiling(size.sample * step)
    curr.N_obs <- mapply(function(rel.counts, n.rare, n.tax) {
      tmp.counts <- replicate(iterations, sample(1:n.tax, size = n.rare, prob = rel.counts, replace = T))
      mean(apply(tmp.counts, 2, function(x) {length(unique(x))}))
    }, rel.counts=as.data.frame(ct.rel), n.rare=curr.sizes, MoreArgs = list(n.tax=n.tax))
    #Append
    results.rarefy <- rbind(results.rarefy, data.frame(
      sample.name = colnames(count.table),
      N.seq = curr.sizes,
      N.obs = curr.N_obs
    ))
  }
  
  #Return
  results.rarefy
}

Hill_Diversity.rarefied <- function(count.table, size=1000, iterations=100, q.H=c(0, 1, 2)) {
  require(plyr)
  
  #Get current sample sizes
  size.sample <- colSums(count.table)
  #Get overall taxa count
  n.tax <- nrow(count.table)
  
  #Get relative counts
  count.table <- as.matrix(count.table)
  ct.rel <- as.matrix(t(t(count.table) / size.sample))
  
  #Preallocate
  D.rarefied <- as.data.frame(matrix(nrow=length(size.sample), ncol=4))
  colnames(D.rarefied) <- c("sample.name", paste0("q.", q.H))
  D.rarefied[, "sample.name"] <- names(size.sample)
  
  #Iteratively generate count tables
  curr.ct <- alply(ct.rel, 2, function(p.vec) {replicate(iterations, table(sample(1:n.tax, size=size, prob=p.vec, replace=T)) / size, simplify=FALSE)})
  #Iterate through q values and calculate rarefied diversities
  for (q.i in q.H) {
    #Handle special cases of q=0 (richness only) and q=1 (exp(Shannon))
    if (q.i == 0) {
      curr.D <- sapply(curr.ct, function(x) {mean(sapply(x, length))})
    } else if (q.i == 1) {
      curr.D <- sapply(curr.ct, function(x) {mean(sapply(x, function(vec) {exp(shannon(vec))}))})
    } else {
      curr.D <- sapply(curr.ct, function(x) {mean(sapply(x, function(vec) {sum(vec ^ q.i) ^ (1/(1-q.i))}))})
    }
    #Replace values for undersampled samples with NA
    curr.D[size.sample < size] <- NA
    #Store in results frame
    D.rarefied[, which(q.H == q.i)+1] <- curr.D
  }
  
  D.rarefied
}
################################################################################
################################################################################

