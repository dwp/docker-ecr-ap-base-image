FROM alpine:3.13

RUN apk add --no-cache alpine-sdk bash curl-dev curl g++ gcc gfortran krb5-dev krb5-libs libffi-dev nodejs npm openssl pkgconfig python3 python3-dev py3-pyzmq linux-pam git \
    && apk add --no-cache py3-lxml libgfortran py3-numpy py3-numpy-dev py3-scipy py3-scikit-learn freetype-dev libjpeg-turbo-dev libpng-dev zlib-dev libgcc libquadmath \
    && apk add --no-cache musl lapack-dev libexecinfo-dev openblas-dev libgomp

RUN npm install -g configurable-http-proxy

RUN python3 -m ensurepip && \
    pip3 install --upgrade pip setuptools wheel pycurl

ADD requirements.txt /srv/jupyterhub/
ARG CRYPTOGRAPHY_DONT_BUILD_RUST=1
RUN pip3 install --default-timeout=100 -r /srv/jupyterhub/requirements.txt

RUN jupyter lab build --minimize=False \
    && jupyter nbextension enable --py --sys-prefix widgetsnbextension \
    && jupyter labextension install @jupyter-widgets/jupyterlab-manager@2.0

RUN python3 -m spacy download en_core_web_sm

WORKDIR /usr/lib/python3.8/site-packages/

RUN jupyter-kernelspec install sparkmagic/kernels/pysparkkernel \
    && jupyter-kernelspec install sparkmagic/kernels/sparkrkernel \
    && jupyter serverextension enable --py sparkmagic

ADD proxy_configuration.py /usr/lib/python3.8/site-packages/proxy_configuration.py
ADD jupyterhub_config.py /etc/jupyterhub/conf/jupyterhub_config.py

# Add message logging
ADD handlers.py /usr/lib/python3.8/site-packages/notebook/services/kernels/handlers.py

# Create template user home
RUN mkdir -p /etc/skel/.sparkmagic /etc/skel/.jupyter/
ADD jupyter_local_conf.py /etc/skel/.jupyter/jupyter_notebook_config.py
ADD template_sparkmagic_config.json /etc/skel/.sparkmagic/config.json

RUN apk del alpine-sdk g++ gcc krb5-dev libffi-dev npm pkgconfig python3-dev py3-numpy-dev zlib-dev

ADD entrypoint.sh /
RUN chmod +x /entrypoint.sh

EXPOSE 8000

HEALTHCHECK --interval=12s --timeout=12s --start-period=20s \  
 CMD wget -O- -S --no-check-certificate -q https://localhost:8000/hub/health
ENTRYPOINT ["/entrypoint.sh"]
CMD ["-f", "/etc/jupyterhub/conf/jupyterhub_config.py"]
