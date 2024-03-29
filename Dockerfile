FROM debian:buster-slim
ARG TARGETPLATFORM
ENV PGDATA=/var/lib/postgresql/13/data

ENV DB_USER=qgis
ENV DB_PASSWORD=qgis
ENV TIMEZONE=UTC

RUN ln -s /usr/bin/dpkg-split /usr/sbin/dpkg-split && \
    ln -s /usr/bin/dpkg-deb /usr/sbin/dpkg-deb && \
    ln -s /bin/rm /usr/sbin/rm && \
    ln -s /bin/tar /usr/sbin/tar
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections && \
    apt-get update && \
    apt-get install -qy git wget gzip tar gnupg2 p7zip-full apt-utils nscd
RUN echo "deb http://deb.debian.org/debian buster contrib non-free" >> /etc/apt/sources.list.d/contrib.list && \
    echo "deb http://deb.debian.org/debian buster-updates contrib non-free" >> /etc/apt/sources.list.d/contrib.list && \
    echo "deb http://apt.postgresql.org/pub/repos/apt buster-pgdg main" > /etc/apt/sources.list.d/pgdg.list
RUN wget --quiet -O /pgsql.key https://www.postgresql.org/media/keys/ACCC4CF8.asc 
RUN apt-key add /pgsql.key
RUN apt-get update 
RUN apt-get -qq install postgresql-13 postgresql-13-postgis-3 postgresql-13-postgis-3-scripts 
RUN apt-get autoclean && rm /pgsql.key

COPY postgres/pg_hba.conf /pg_hba.conf
COPY postgres/pginit.sql /pginit.sql
COPY postgres/startdb.sh /startdb.sh

VOLUME [${PGDATA}]

ENTRYPOINT [ "/startdb.sh" ]

STOPSIGNAL SIGINT
EXPOSE 5432

CMD su - postgres -c "/usr/lib/postgresql/13/bin/postgres -D ${PGDATA}"
