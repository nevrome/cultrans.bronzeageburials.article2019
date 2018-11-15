#!/usr/bin/env Rscript

bookdown::render_book(
  "index.Rmd",
  output_file = "rendered_article/article.pdf",
  output_dir = "rendered_article",
  output_options = list(delete_merged_file = TRUE)
)
