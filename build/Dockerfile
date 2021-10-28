ARG ROOT_CONTAINER=ubuntu:focal

FROM $ROOT_CONTAINER

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update --yes && \
    apt-get install --yes --no-install-recommends \
    tini \
    wget \
    ca-certificates \
    sudo \
    locales \
    fonts-liberation \
    run-one && \
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen

RUN apt-get install --yes --no-install-recommends \
    # Common useful utilities
    git \
    nano-tiny \
    tzdata \
    unzip \
    # git-over-ssh
    openssh-client \
    libsm6 \
    libxext-dev \
    libxrender1 \
    lmodern \
    netcat nodejs software-properties-common \
    # nbconvert dependencies
    # https://nbconvert.readthedocs.io/en/latest/install.html#installing-tex
    texlive-xetex \
    texlive-fonts-recommended \
    texlive-plain-generic

RUN apt-get install --yes --no-install-recommends build-essential libcurl4-openssl-dev fonts-dejavu curl gfortran libkrb5-dev nodejs npm openssl python3 python3-pip python3-distutils python3-dev libpam0g \
    && apt-get install --yes --no-install-recommends python3-lxml libgfortran5 python3-numpy python3-numpy-dev python3-scipy python3-sklearn python3-sklearn-lib libfreetype-dev libjpeg-turbo8-dev libpng-dev libgcc-10-dev libquadmath0 \
    && apt-get install --yes --no-install-recommends musl libblas-dev liblapack-dev libopenblas-dev libxml2-dev libxslt-dev

RUN apt-get clean && rm -rf /var/lib/apt/lists/*

RUN npm install -g configurable-http-proxy
RUN pip3 install --upgrade pip setuptools wheel pycurl lxml

ADD requirements.txt /srv/jupyterhub/
ARG CRYPTOGRAPHY_DONT_BUILD_RUST=1
RUN pip3 install --default-timeout=200 --ignore-installed -r /srv/jupyterhub/requirements.txt

RUN jupyter lab build --minimize=False \
    && jupyter nbextension enable --py --sys-prefix widgetsnbextension \
    && jupyter labextension install @jupyter-widgets/jupyterlab-manager@2.0

RUN python3 -m spacy download en_core_web_sm

WORKDIR /usr/local/lib/python3.8/dist-packages/

RUN jupyter-kernelspec install sparkmagic/kernels/pysparkkernel \
    && jupyter-kernelspec install sparkmagic/kernels/sparkrkernel \
    && jupyter serverextension enable --py sparkmagic

ADD proxy_configuration.py /usr/local/lib/python3.8/dist-packages/proxy_configuration.py
ADD jupyterhub_config.py /etc/jupyterhub/conf/jupyterhub_config.py

# Add message logging
ADD handlers.py /usr/local/lib/python3.8/dist-packages/notebook/services/kernels/handlers.py

# Create template user home
RUN mkdir -p /etc/skel/.sparkmagic /etc/skel/.jupyter/
ADD jupyter_local_conf.py /etc/skel/.jupyter/jupyter_notebook_config.py
ADD template_sparkmagic_config.json /etc/skel/.sparkmagic/config.json

ADD entrypoint.sh /
RUN chmod +x /entrypoint.sh

EXPOSE 8000

HEALTHCHECK --interval=12s --timeout=12s --start-period=20s \  
 CMD wget -O- -S --no-check-certificate -q https://localhost:8000/hub/health
ENTRYPOINT ["/entrypoint.sh"]
CMD ["-f", "/etc/jupyterhub/conf/jupyterhub_config.py"]
