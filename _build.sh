#!/usr/bin/env Rscript

rmarkdown::render(
  "article/index.Rmd",
  output_dir = "rendered_article",
  output_file = "article.pdf"
)
