#!/bin/bash

host="$1"
dbname="$2"
user="$3"
password="$4"
pgdbname="$5"

msg="$(echo "SELECT 'CREATE DATABASE \"$dbname\" TEMPLATE template_postgis' 
             WHERE NOT EXISTS 
             (SELECT FROM pg_database WHERE datname = '$dbname')
             \gexec"\
             | \
             psql "host=$host dbname=$pgdbname user=$user password=$password")"

if [ "$msg" = "CREATE DATABASE" ] ; then
	rt=1
else
	msg=$(psql "host=$host dbname=$dbname user=$user password=$password" -t -c \
                   "SELECT COUNT(*) 
                    FROM information_schema.tables 
                    WHERE table_catalog = '$dbname' 
                    AND table_name = 'ax_flurstueck'")
	if [ $msg = 0 ] ; then
		rt=1
	else
		msg=$(psql "host=$host dbname=$dbname user=$user password=$password" -t -c \
                           "SELECT COUNT(*) 
                            FROM archikart.ax_flurstueck")
		if [ $msg = 0 ] ; then
			rt=1
		else
			rt=2
		fi
	fi
fi

echo $rt
