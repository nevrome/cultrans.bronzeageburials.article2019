FROM rocker/tidyverse:3.5.0

WORKDIR "home/rstudio"

COPY ./DESCRIPTION ./
COPY ./analysis/ ./analysis/

RUN Rscript analysis/code/create_directories.R

RUN R -e "devtools::install('.', dep = TRUE)"

RUN find . -type d -exec chmod 777 {} \;
