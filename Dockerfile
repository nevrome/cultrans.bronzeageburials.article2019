FROM rocker/tidyverse:3.5.0

COPY ./DESCRIPTION /home/rstudio/
COPY ./analysis/* /home/rstudio/analysis/
RUN mkdir /home/rstudio/analysis/figures

RUN R -e "devtools::install('/home/rstudio', dep = TRUE)"

RUN find /home/rstudio -type d -exec chmod 777 {} \;
