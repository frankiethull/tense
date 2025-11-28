# fmt: skip
#' Get Semantic Lexicons
#'
#' Returns ranked lists of words for specific time-series dimensions.
#'
#' @return Character vector.
#' @export
get_lexicon <- function() {
  # A curated gradient of 50 distinct intensity states
  # From Absolute Doom -> Neutral -> Absolute Bliss
  words <- c(
    "catastrophic", "ruinous", "devastating", "horrific", "terrible",
    "awful", "dreadful", "miserable", "painful", "depressing",
    "unfortunate", "bad", "negative", "poor", "lacking", "disappointing",
    "unsatisfactory", "weak", "struggling", "shaky", "uncertain",
    "mediocre", "average", "neutral", "stable", "steady", "okay",
    "fine", "acceptable", "decent", "satisfactory", "improving",
    "promising", "positive", "good", "strong", "solid", "great",
    "excellent", "superb", "wonderful", "fantastic", "brilliant",
    "amazing", "incredible", "perfect", "magnificent", "divine",
    "glorious", "legendary"
  )
  return(words)
}
