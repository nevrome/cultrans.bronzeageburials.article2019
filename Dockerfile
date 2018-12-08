FROM rocker/tidyverse:3.5.0

RUN apt-get --yes --force-yes update -qq
RUN apt-get install --yes udunits-bin libproj-dev libgeos-dev libgdal-dev libgdal-dev libudunits2-dev

WORKDIR "home/rstudio"

COPY ./DESCRIPTION ./

RUN R -e "devtools::install('.', dep = TRUE)"

COPY ./analysis/ ./analysis/

RUN Rscript analysis/code/create_directories.R

RUN find . -type d -exec chmod 777 {} \;
