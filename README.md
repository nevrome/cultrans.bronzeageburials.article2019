<!-- README.md is generated from README.Rmd. Please edit that file -->

[![Build
Status](https://travis-ci.com/nevrome/cultrans.bronzeageburials.article2019.svg?token=vxsQ9RjxoGASGtX4Q8jc&branch=master)](https://travis-ci.com/nevrome/cultrans.bronzeageburials.article2019)
[![Last-changedate](https://img.shields.io/badge/last%20change-2019--03--31-brightgreen.svg)](https://github.com/nevrome/nevrome/cultrans.bronzeageburials.article2019/commits/master)
[![minimal R
version](https://img.shields.io/badge/R%3E%3D-3.5.0-brightgreen.svg)](https://cran.r-project.org/)
[![ORCiD](https://img.shields.io/badge/ORCiD-0000--0003--3448--5715-green.svg)](http://orcid.org/0000-0003-3448-5715)

Research compendium for 'Evaluating Cultural Transmission in Bronze Age burial rites of Central, Northern and North-western Europe using radiocarbon data'
----------------------------------------------------------------------------------------------------------------------------------------------------------

### Compendium DOI:

<http://dx.doi.org/10.17605/OSF.IO/B6NP2>

The files at the URL above will generate the results as found in the
publication. The files hosted at
<https://github.com/nevrome/cultrans.bronzeageburials.article2019> are
the development versions and may have changed since the paper was
published

### Author of this repository:

Clemens Schmid (<clemens@nevrome.de>)

### Published in:

Not yet published: In review.

### Abstract:

European Bronze Age archaeology traditionally focusses on two major
dimensions to categorise burials -- although there is an immense
variability of attendant phenomena within this spectrum -- flat graves
versus burial mounds and cremation versus inhumation. These traits are
an indispensable ingredient for common archaeological narratives of
sociocultural interaction and cultural evolution. This paper presents a
quantitative reconstruction of the general trends in the distribution of
Bronze Age burial traditions based on bulk radiocarbon data and employs
the resulting time series for the estimation of macro-regional cultural
distance. Despite the relatively small amount of input data the trend
reconstruction fits to established archaeological observations for
prehistoric Europe. The comparison of cultural and spatial distance
leads to the remarkable result of no significant permanent correlation,
which indicates that the spread of the relevant aspects of burial
traditions can not be explained with simple diffusion models. Instead a
more complex process of cultural transmission has to be considered.

### Keywords:

Bronze Age, Burial Traditions, Cultural Transmission, Radiocarbon Dating

### Overview of contents:

This repository contains text, code and data for the paper. The paper is
rendered via continuous integration and can be downloaded from the
[document
branch](https://github.com/nevrome/cultrans.bronzeageburials.article2019/tree/document),
so
[here](https://github.com/nevrome/cultrans.bronzeageburials.article2019/blob/document/article.pdf).

The `analysis` directory contains `code` and `data` to reproduce the
preparations, calculations and figure renderings in this paper. The
`article` directory contains the text for the paper in *.Rmd* format.

### How to reproduce:

As the data and code in this repository are complete and self-contained,
it can be reproduced with any R environment (\> version 3.5.0). The
necessary package dependencies are documented in the `DESCRIPTION` file
and can be installed manually or automatically with
`devtools::install()`. If it's not possible any more to construct a
working environment with these methods due to technological progress,
one can use the Docker image.

A Docker image is a lightweight GNU/Linux virtual computer that can be
run as a piece of software on Windows, Linux, and OSX. To capture the
complete computational environment used for this project we have a
Dockerfile that specifies how to make the Docker image that we developed
this project in. The Docker image includes all of the software
dependencies needed to run the code in this project, including the data
and code itself. To launch the Docker image for this project, first,
[install Docker](https://docs.docker.com/installation/) on your computer
and download the `.tar` file with the paper image from the relevant
repository (see DOI). At the Docker prompt, you can load and run the
image with:

    docker load -i cultransbronze19_docker_image.tar
    docker run -e PASSWORD=cultransbronze19 -dp 8787:8787 --name cultransbronze19 cultransbronze19

This will start a server instance of RStudio. Then open your web browser
at localhost:8787 or run `docker-machine ip default` in the shell to
find the correct IP address, and log in with
**rstudio/cultransbronze19**. Once logged in, use the Files pane (bottom
right) to navigate to the script files. More information about using
RStudio in Docker is available at the
[Rocker](https://github.com/rocker-org)
[wiki](https://github.com/rocker-org/rocker/wiki/Using-the-RStudio-image)
pages.

We developed and tested the package on this Docker container, so this is
the only platform that we're confident it works on. It was built and
stored with:

    docker build -t cultransbronze19 .
    docker save -o cultransbronze19_docker_image.tar cultransbronze19

### Licenses:

Code: MIT <http://opensource.org/licenses/MIT> year: 2019, copyright
holder: Clemens Schmid

Data: Please see the license agreements of Radon-B and Natural Earth
data

Text: Please see the license agreements of the Adaptive Behavior journal
