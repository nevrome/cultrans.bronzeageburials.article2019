FROM rocker/tidyverse:3.6.0

RUN apt-get --yes --force-yes update -qq
RUN apt-get install --yes udunits-bin libproj-dev libgeos-dev libgdal-dev libgdal-dev libudunits2-dev

WORKDIR "home/rstudio"

COPY ./DESCRIPTION ./

RUN R -e "devtools::install('.', dep = TRUE)"

COPY ./analysis/ ./analysis/
COPY ./_run_analysis.sh ./

RUN chmod +x ./_run_analysis.sh
RUN ./_run_analysis.sh

RUN find . -type d,f -exec chmod 777 {} \;
