FROM nginx

RUN apt-get update \
 && apt-get install -y gettext

COPY run.sh /bin/run.sh
RUN chmod +x /bin/run.sh

CMD /bin/run.sh
