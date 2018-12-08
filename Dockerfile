FROM rocker/tidyverse:3.5.0

WORKDIR "home/rstudio"

COPY ./DESCRIPTION ./
COPY ./analysis/ ./analysis/

RUN Rscript analysis/code/create_directories.R

RUN find . -type d -exec chmod 777 {} \;

RUN apt-get --yes --force-yes update -qq
RUN apt-get install --yes udunits-bin libproj-dev libgeos-dev libgdal-dev libgdal-dev libudunits2-dev

RUN R -e "devtools::install('.', dep = TRUE)"
