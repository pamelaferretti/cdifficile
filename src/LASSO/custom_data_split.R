# create data split with one additional variable


create.data.split.2 <- function(siamcat, num.folds = 2, num.resample = 1,
                                stratify = TRUE, 
                                dataset = NULL,
                                inseparable = NULL, 
                                verbose = 1) {
  require("SIAMCAT")
  if (is.null(dataset)){
    return(create.data.split(siamcat, num.folds, num.resample, stratify,
                             inseparable, verbose))
  }
  
  if (verbose > 1)
    message("+ starting create.data.split")
  s.time <- proc.time()[3]
  
  label    <- label(siamcat)
  labelNum <- as.numeric(label$label)
  names(labelNum) <- names(label$label)
  exm.ids <- names(labelNum)
  
  stopifnot(dataset %in% colnames(meta(siamcat)))
  dataset.info <- unlist(meta(siamcat)[[dataset]])
  names(dataset.info) <- rownames(meta(siamcat))
  
  if (is.null(inseparable) || inseparable == "" ||
      toupper(inseparable) == "NULL" ||
      toupper(inseparable) == "NONE" ||
      toupper(inseparable) == "UNKNOWN") {
    inseparable <- NULL
  }
  
  # parse label description
  classes <- sort(label$info)
  
  ### check arguments
  if (num.resample < 1) {
    if (verbose > 1)
      message(paste0("+++ Resetting num.resample = 1 (",
                     num.resample,
                     " is an invalid number of resampling rounds)"))
    num.resample <- 1
  }
  if (num.folds < 2) {
    if (verbose > 1)
      message(paste0("+++ Resetting num.folds = 2 (",num.folds,
                     " is an invalid number of folds)"))
    num.folds <- 2
  }
  if (!is.null(inseparable) && stratify) {
    if (verbose > 1)
      message(
        "+++ Resetting stratify to FALSE (Stratification is not
        supported when inseparable is given"
      )
    stratify <- FALSE
  }
  if (num.folds >= length(labelNum)) {
    if (verbose > 1)
      message("+++ Performing un-stratified leave-one-out (LOO)
              cross-validation")
    stratify <- FALSE
    num.folds <- length(labelNum) - 1
  }
  if (!is.null(inseparable) && is.null(meta(siamcat))) {
    stop("Meta-data must be provided if the inseparable parameter is not
         NULL")
  }
  if (!is.null(inseparable)) {
    if (is.numeric(inseparable) && length(inseparable) == 1) {
      stopifnot(inseparable <= ncol(meta(siamcat)))
    } else if (is.character(inseparable) &&
               length(inseparable == 1)) {
      stopifnot(inseparable %in% colnames(meta(siamcat)))
    } else {
      stop(
        "Inseparable parameter must be either a single column index
        or a single column name of metadata matrix"
      )
    }
    }
  
  train.list <- list(NULL)
  test.list <- list(NULL)
  
  
  for (r in seq_len(num.resample)) {
    labelNum <- sample(labelNum)
    foldid <-
      assign.fold.2(
        label = labelNum,
        num.folds = num.folds,
        stratified = stratify,
        inseparable = inseparable,
        batch = dataset.info,
        meta = meta(siamcat)[names(labelNum),],
        verbose = verbose
      )
    names(foldid) <- names(labelNum)
    stopifnot(length(labelNum) == length(foldid))
    stopifnot(length(unique(foldid)) == num.folds)
    
    train.temp <- list(NULL)
    test.temp <- list(NULL)
    
    if (verbose > 1)
      message(paste("+ resampling round", r))
    for (f in seq_len(num.folds)) {
      # make sure each fold contains examples from all classes for
      # stratify==TRUE should be tested before assignment of
      # test/training set
      if (stratify) {
        stopifnot(all(sort(unique(
          labelNum[foldid == f]
        )) == classes))
      }
      # select test examples
      test.idx <- which(foldid == f)
      train.idx <- which(foldid != f)
      train.temp[f] <- list(names(foldid)[train.idx])
      test.temp[f] <- list(names(foldid)[test.idx])
      # for startify==FALSE, all classes must only be present in the
      # training set e.g. in leave-one-out CV, the test fold
      # cannot contain all classes
      if (!stratify) {
        stopifnot(all(sort(unique(
          labelNum[foldid != f]
        )) == classes))
      }
      stopifnot(length(intersect(train.idx, test.idx)) == 0)
      if (verbose > 2)
        message(paste(
          "+++ fold ",
          f,
          " contains ",
          sum(foldid == f),
          " samples"
        ))
    }
    train.list[[r]] <- train.temp
    test.list[[r]] <- test.temp
  }
  
  data_split(siamcat) <- list(
    training.folds = train.list,
    test.folds = test.list,
    num.resample = num.resample,
    num.folds = num.folds
  )
  e.time <- proc.time()[3]
  if (verbose > 1)
    message(paste(
      "+ finished create.data.split in",
      formatC(e.time - s.time, digits = 3),
      "s"
    ))
  if (verbose == 1)
    message("Features splitted for cross-validation successfully.")
  return(siamcat)
  }




#' @keywords internal
assign.fold.2 <- function(label,num.folds,stratified,inseparable = NULL,
                          meta = NULL, batch, verbose = 1) {
    if (verbose > 2)
      message("+++ starting assign.fold")
    foldid <- rep(0, length(label))
    classes <- sort(unique(label))
    batch <- batch[names(label)]
    # Transform number of classes into vector of 1 to x for looping over.
    # stratify positive examples
    if (stratified) {
      # If stratify is TRUE, make sure that num.folds does not exceed the
      # maximum number of examples for the class with
      # the fewest training examples.
      if (any(as.data.frame(table(label))[, 2] < num.folds)) {
        stop(
          "+++ Number of CV folds is too large for this data set to
          maintain stratification. Reduce num.folds or turn
          stratificationoff. Exiting."
        )
      }
      for (c in seq_along(classes)) {
        for (b in unique(batch)){
          idx <- which(label == classes[c] & batch ==b)
          if (length(idx) == 0){next}
          foldid[idx] <- sample(rep(seq_len(num.folds),
                                    length.out = length(idx)))
          }
        }
      } else {
        # If stratify is not TRUE, make sure that num.sample is not
        # bigger than number.folds
        if (length(label) <= num.folds) {
          warning(
            "+++ num.samples is exceeding number of folds, setting
            CV to (k-1) unstratified CV"
          )
          num.folds <- length(label) - 1
        }
        if (!is.null(inseparable)) {
          strata <- unique(meta[[inseparable]])
          sid <-
            sample(rep(seq_len(num.folds), length.out =
                         length(strata)))
          for (s in seq_along(strata)) {
            idx <- which(meta[[inseparable]] == strata[s])
            foldid[idx] <- sid[s]
          }
          stopifnot(all(!is.na(foldid)))
        } else {
          foldid <- sample(rep(seq_len(num.folds),
                               length.out = length(label)))
        }
      }
    # make sure that for each test fold the training fold (i.e. all other
    # folds together) contain examples from all classes except for
    # stratified CV
    if (!stratified) {
      for (f in seq_len(num.folds)) {
        stopifnot(all(sort(unique(label[foldid != f])) == classes))
      }
    } else {
      for (f in seq_len(num.folds)) {
        stopifnot(all(sort(unique(label[foldid == f])) == classes))
      }
    }
    
    stopifnot(length(label) == length(foldid))
    if (verbose > 2)
      message("+++ finished assign.fold")
    return(foldid)
}


