#!/bin/bash
timedatectl set-timezone $TIMEZONE
mkdir $PGDATA && \
chown -R postgres:postgres $PGDATA && \
su postgres -c '/usr/lib/postgresql/13/bin/pg_ctl -D $PGDATA init' && \
mv /pg_hba.conf $PGDATA/ && \
mkdir -p $PGDATA/fk_conf && \
echo "include_dir = '$PGDATA/fk_conf'" >> $PGDATA/postgresql.conf && \
echo "listen_addresses =  '*'" >> $PGDATA/fk_conf/listen.conf && \
chown postgres:postgres $PGDATA/pg_hba.conf && \
su postgres -c '/usr/lib/postgresql/13/bin/pg_ctl -D $PGDATA start' && \
su postgres -c '/usr/lib/postgresql/13/bin/psql -d template1 -f /pginit.sql' && \
su postgres -c '/usr/lib/postgresql/13/bin/pg_ctl -D $PGDATA stop -m smart' && \
exec "$@"