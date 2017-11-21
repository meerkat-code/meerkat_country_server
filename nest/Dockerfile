FROM buildpack-deps:jessie

# http://bugs.python.org/issue19846
# > At the moment, setting "LANG=C" on a Linux system *fundamentally breaks Python 3*, and that's not OK.
ENV LANG C.UTF-8
ENV MINICONDA_PACKAGE Miniconda3-4.3.11-Linux-x86_64.sh
ENV PYT_VERSION python3.6

RUN apt-get update &&\
    apt-get -y install postgresql-client libpq-dev libgeos-c1 &&\
    apt-get clean

ENV PATH=/miniconda/bin:${PATH}
ENV PYTHONPATH=/miniconda/lib/{PYT_VERSION}/site-packages:/var/www/meerkat_libs

RUN curl -LO https://repo.continuum.io/miniconda/${MINICONDA_PACKAGE}  &&\
    bash ${MINICONDA_PACKAGE} -p /miniconda -b &&\
    rm ${MINICONDA_PACKAGE} &&\
    conda update -y conda &&\
    conda install -y pandas &&\
    pip install uwsgi

RUN mkdir -p /var/www/meerkat_nest
WORKDIR /var/www/meerkat_nest

COPY requirements.txt /var/www/meerkat_nest/requirements.txt
RUN pip install -r requirements.txt

COPY uwsgi/app.ini /var/www/uwsgi/app.ini
COPY run /usr/bin/run
RUN chmod +x /usr/bin/run

CMD ["run"]
