#!/bin/sh

psql postgres://postgres@127.0.0.1:5432 \
	-c 'DROP DATABASE IF EXISTS new' -c 'CREATE DATABASE new'
psql postgres://postgres@127.0.0.1:5432/new \
	-f ../db/init/init.sql

pgdiff() {
	pgquarrel --{source,target}-host=127.0.0.1 \
		--{source,target}-username=postgres \
		--source-dbname=$1 --target-dbname=$2
}

{
	echo
	echo
	echo "-- up.sql"
	pgdiff new postgres

	echo
	echo
	echo "-- down.sql"
	pgdiff postgres new
} | sed 's/^--.*$/\x1b[2m\0\x1b[m/'
