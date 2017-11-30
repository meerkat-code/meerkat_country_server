FROM postgres:10.1

MAINTAINER Tomasz Sabala

RUN apt-get update && apt-get install -y python3-dev lzop pv daemontools expect curl sudo
RUN curl -O https://bootstrap.pypa.io/get-pip.py && \
   python3 get-pip.py && \
   export LC_ALL=C && \
   python3 -m pip install wal-e[aws]
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* get-pip.py

RUN mkdir -p /home/postgres && chown postgres:postgres /home/postgres
