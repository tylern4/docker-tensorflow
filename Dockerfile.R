FROM tensorflow/tensorflow

ENV CRAN_URL https://cloud.r-project.org/

RUN apt-get update \
    && apt-get -y upgrade \
    && apt-get -y install zsh r-base gdebi-core \
      apt-transport-https gdebi-core libapparmor1 \
      libcurl4-openssl-dev libssl-dev libxml2-dev python-virtualenv

RUN grep '^DISTRIB_CODENAME' /etc/lsb-release \
        | cut -d = -f 2 \
        | xargs -I {} echo "deb ${CRAN_URL}bin/linux/ubuntu {}/" \
        | tee -a /etc/apt/sources.list \
      && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9 \
      && apt-get -y update \
      && apt-get -y upgrade \
      && apt-cache -q search r-cran-* \
        | awk '$1 !~ /^r-cran-r2jags$/ { p = p" "$1 } END{ print p }' \
        | xargs apt-get -y install r-base \
      && apt-get clean

RUN R -e "\
      update.packages(ask = FALSE, repos = '${CRAN_URL}'); \
      pkgs <- c('dbplyr', 'devtools', 'docopt', 'doParallel', 'foreach', 'gridExtra', 'tidyverse'); \
      install.packages(pkgs = pkgs, dependencies = TRUE, repos = '${CRAN_URL}'); \
      sapply(pkgs, require, character.only = TRUE);"

RUN R -e "\
      update.packages(ask = FALSE, repos = '${CRAN_URL}'); \
      pkgs <- c('tensorflow'); \
      install.packages(pkgs = pkgs, dependencies = TRUE, repos = '${CRAN_URL}'); \
      sapply(pkgs, require, character.only = TRUE); \
      library(tensorflow); \
      install_tensorflow();"

RUN curl -sS https://s3.amazonaws.com/rstudio-server/current.ver \
        | xargs -I {} curl -sS http://download2.rstudio.org/rstudio-server-{}-amd64.deb -o /tmp/rstudio.deb \
      && gdebi -n /tmp/rstudio.deb \
      && rm -rf /tmp/*

RUN useradd -m -d /home/rstudio rstudio \
      && echo rstudio:rstudio \
        | chpasswd


ENTRYPOINT ["/bin/bash"]
