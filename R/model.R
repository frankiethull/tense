#' Initialize Tense Model
#'
#' @param model_name LLM model name.
#' @param temperature a temperature for the LLM
#' @param context_window Steps to look back.
#' @export
tense_init <- function(
  model_name = "llama3",
  temperature = 0.9,
  context_window = 40
) {
  chat_client <- tryCatch(
    {
      ellmer::chat_ollama(
        model = model_name,
        params = list(temperature = temperature)
      )
    },
    error = function(e) stop("Ollama connection failed.")
  )

  structure(
    list(
      client = chat_client,
      model_name = model_name,
      context_window = context_window,
      lexicon = get_lexicon(),
      history = NULL,
      stats = NULL
    ),
    class = "tense_model"
  )
}

#' Fit Tense Model
#'
#' Decomposes data and learns statistics for all dimensions.
#' @export
tense_fit <- function(model, data) {
  mu <- mean(data, na.rm = TRUE)
  sigma <- sd(data, na.rm = TRUE)

  # Guard against zero variance
  if (is.na(sigma) || sigma == 0) {
    stop("Standard deviation is zero; cannot normalize data.")
  }

  norm_data <- (data - mu) / sigma
  model$stats <- list(mu = mu, sigma = sigma)
  model$history <- norm_data
  return(model)
}
