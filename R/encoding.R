#' Encode: Numeric -> Sentiment Word
#' @param x Numeric vector (standardized)
#' @param lexicon The ordered character vector
encode_sentiment <- function(x, lexicon) {
  n_bins <- length(lexicon)

  # 1. Convert Z-score to Probability (Percentile)
  # pnorm handles the distribution mapping better than sigmoid for standardized data
  # x = 0 -> p = 0.5
  # x = 1.96 -> p = 0.975
  p <- pnorm(x)

  # 2. Map Probability to Integer Index
  # Example: 50 bins.
  # p=0.01 (1st percentile) -> 0.5 -> ceiling -> 1
  # p=0.50 (50th percentile) -> 25 -> ceiling -> 25
  indices <- ceiling(p * n_bins)

  # 3. Safety Clamping (Handle theoretical infinities or floating point edges)
  indices[indices < 1] <- 1
  indices[indices > n_bins] <- n_bins

  return(lexicon[indices])
}

#' Decode: Sentiment Word -> Numeric
#' @param words Vector of words
#' @param lexicon The ordered character vector
decode_sentiment <- function(words, lexicon) {
  n_bins <- length(lexicon)

  # 1. Find index in lexicon (case-insensitive)
  indices <- match(tolower(words), tolower(lexicon))

  # 2. Handle Hallucinations (Safety fallback)
  if (any(is.na(indices))) {
    warning(
      "Found words not in lexicon. Imputing with the middle (neutral) value."
    )
    middle_index <- ceiling(n_bins / 2)
    indices[is.na(indices)] <- middle_index
  }

  # 3. Determine "Center" Probability of the Bin
  # With 50 bins, each bin is 2% (0.02) wide.
  # Bin 1 covers 0.00-0.02. Center is 0.01.
  # Formula: (Index - 0.5) / N
  p_center <- (indices - 0.5) / n_bins

  # 4. Convert Probability back to Z-score (Inverse Normal)
  values <- qnorm(p_center)

  return(values)
}
