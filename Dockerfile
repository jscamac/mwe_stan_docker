FROM rocker/tidyverse:3.3.2
MAINTAINER James Camac <james.camac@gmail.com>

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    git \
    && apt-get clean \
    && apt-get autoremove \
    && rm -rf var/lib/apt/lists/*

RUN install2.r -r "https://mran.revolutionanalytics.com/snapshot/2016-11-25/" --error \
    --deps "TRUE" \
    rstan

RUN rm -rf /tmp/downloaded_packages/ /tmp/*.rds

RUN git clone https://github.com/jscamac/mwe_stan_docker /home/mwe_stan_docker

WORKDIR /home/mwe_stan_docker

CMD ["R"]

