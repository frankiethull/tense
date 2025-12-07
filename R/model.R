#' Initialize Tense Model
#'
#' @param model_name LLM model name for `ellmer::chat()` API interface
#' @param temperature a temperature for the LLM
#' @param seed Sets the random number seed to use for generation.
#' Setting this to a specific number will make the model generate the same text for the same prompt.
#' @param top_k Reduces the probability of generating nonsense.
#' A higher value (e.g. 100) will give more diverse answers,
#' while a lower value (e.g. 10) will be more conservative
#' @param top_p Works together with top-k. A higher value (e.g., 0.95)
#' will lead to more diverse text,
#' while a lower value (e.g., 0.5) will generate more focused and conservative text.
#' @param ... additional LLM parameter controls
#' @param context_window Steps to look back.
#' @export
tense_init <- function(
  model_name = "llama3",
  temperature = 0.9,
  seed = 17,
  top_k = 10,
  top_p = 0.5,
  context_window = 40,
  ...
) {
  chat_client <- tryCatch(
    {
      ellmer::chat(
        name = model_name,
        params = list(
          temperature = temperature,
          seed = seed,
          top_k = top_k,
          top_p = top_p,
          ... = ...
        )
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
