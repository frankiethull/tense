#' Forecast
#'
#' @param model Fitted tense object.
#' @param h Horizon.
#' @export
tense_predict <- function(model, h = 10) {
  # 1. Get Context
  n <- length(model$history)
  win <- min(model$context_window, n)
  input_data <- model$history[(n - win + 1):n]

  # 2. ENCODE to Words
  input_words <- encode_sentiment(input_data, model$lexicon)
  input_str <- paste(input_words, collapse = ", ")

  # 3. Prompt
  prompt <- glue::glue(
    "
I have a log of emotional intensity tracked over time. The feeling moves up and down.
Current Stream: {input_str}
Task: Predict the next {h} emotional states in this narrative.

Rules:
1. You must strictly use words from standard English intensity (e.g., bad, neutral, good, great).
2. Follow the momentum of the stream.
3. Return EXACTLY {h} words separated by commas.
4. Output nothing else.
"
  )

  # 4. LLM Generation
  message("LLM Learning & Inferring ... ")
  response <- model$client$chat(prompt)

  # 5. Clean Response
  clean_text <- stringr::str_replace_all(response, "[[:punct:]&&[^,]]", "")
  pred_words <- stringr::str_trim(unlist(str_split(clean_text, ",")))
  pred_words <- pred_words[pred_words != ""]

  if (length(pred_words) > h) {
    pred_words <- pred_words[1:h]
  }
  if (length(pred_words) < h) {
    pred_words <- c(pred_words, rep("neutral", h - length(pred_words)))
  }

  message(paste("Predicted Lexicon:", paste(head(pred_words), collapse = ", ")))

  # 6. DECODE
  pred_z <- decode_sentiment(pred_words, model$lexicon)

  # 7. Denormalize
  pred_final <- (pred_z * model$stats$sigma) + model$stats$mu
  return(pred_final)
}
