#!/usr/bin/env Rscript

rmarkdown::render(
  "rendered_article/index.Rmd",
  output_dir = "rendered_article",
  output_file = "article.pdf"
)
