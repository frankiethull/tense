#' Encode: Numeric -> Sentiment Word
#' @param x Numeric vector (standardized)
#' @param lexicon The ordered character vector
encode_sentiment <- function(x, lexicon) {
  n_bins <- length(lexicon)

  # 1. Sigmoid Transform
  p <- 1 / (1 + exp(-x))

  # 2. Map (0,1) to integer index (1 to n_bins)
  indices <- ceiling(p * n_bins)
  indices[indices == 0] <- 1
  indices[indices > n_bins] <- n_bins

  return(lexicon[indices])
}

#' Decode: Sentiment Word -> Numeric
#' @param words Vector of words
#' @param lexicon The ordered character vector
decode_sentiment <- function(words, lexicon) {
  # 1. Find index in lexicon (case-insensitive)
  indices <- match(tolower(words), lexicon)

  # 2. Handle hallucinations (words not in list)
  if (any(is.na(indices))) {
    warning("LLM used words outside the lexicon. Imputing with 'neutral'.")
    indices[is.na(indices)] <- which(lexicon == "neutral")
  }

  # 3. Inverse Sigmoid (Logit)
  n_bins <- length(lexicon)
  p <- indices / n_bins
  p <- pmin(pmax(p, 0.01), 0.99)
  values <- log(p / (1 - p))

  return(values)
}
