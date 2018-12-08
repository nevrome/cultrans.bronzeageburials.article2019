FROM rocker/tidyverse:3.5.0

COPY . /home/rstudio

RUN R -e "devtools::install('/home/rstudio', dep = TRUE)"
