#!/bin/bash
set -e

ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
mkdir -p $PGDATA 
chown -R postgres:postgres $PGDATA 
su postgres -c '/usr/lib/postgresql/13/bin/pg_ctl -D $PGDATA init' 
mv /pg_hba.conf $PGDATA/ 
mkdir -p $PGDATA/fk_conf 
echo "include_dir = '$PGDATA/fk_conf'" >> $PGDATA/postgresql.conf 
echo "listen_addresses =  '*'" >> $PGDATA/fk_conf/listen.conf 
chown postgres:postgres $PGDATA/pg_hba.conf 
su postgres -c '/usr/lib/postgresql/13/bin/pg_ctl -D $PGDATA start' 
su postgres -c '/usr/lib/postgresql/13/bin/psql -d template1 -f /pginit.sql' 
su postgres -c "/usr/lib/postgresql/13/bin/psql -d template1 -c \"alter user postgres with password '$DB_PASSWORD';\"" 
su postgres -c "/usr/lib/postgresql/13/bin/psql -d template1 -c \"create user $DB_USER with createdb password '$DB_PASSWORD';\"" 

su postgres -c '/usr/lib/postgresql/13/bin/pg_ctl -D $PGDATA stop -m smart' 
exec "$@"