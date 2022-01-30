FROM debian:buster-slim
ARG TARGETPLATFORM
ENV PGDATA=/var/lib/postgresql/13/data

ENV DB_USER=qgis
ENV DB_PASSWORD=qgis
ENV TIMEZONE=UTC

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections && \
    apt-get update && \
    apt-get install -qy git wget gzip tar gnupg2 p7zip-full apt-utils
RUN echo "deb http://deb.debian.org/debian buster contrib non-free" >> /etc/apt/sources.list.d/contrib.list && \
    echo "deb http://deb.debian.org/debian buster-updates contrib non-free" >> /etc/apt/sources.list.d/contrib.list && \
    echo "deb http://apt.postgresql.org/pub/repos/apt buster-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -  && \
    apt-get update && \
    apt-get -qq install postgresql-13 postgresql-13-postgis-3 postgresql-13-postgis-3-scripts && \
    apt-get autoclean 

COPY postgres/pg_hba.conf /pg_hba.conf
COPY postgres/pginit.sql /pginit.sql
COPY postgres/startdb.sh /startdb.sh

VOLUME [${PGDATA}]

ENTRYPOINT [ "/startdb.sh" ]

STOPSIGNAL SIGINT
EXPOSE 5432

CMD su - postgres -c "/usr/lib/postgresql/13/bin/postgres -D ${PGDATA}"
