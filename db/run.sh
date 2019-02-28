#!/bin/sh

cd "$(dirname "$(readlink -f -- "$0")")"

mkdir -p data

docker run \
	--rm \
	--name hedlx-bbs-staging \
	--volume $PWD/init:/docker-entrypoint-initdb.d:ro \
	--volume $PWD/data:/var/lib/postgresql/data \
	--publish 127.0.0.1:5432:5432 \
	-i \
	postgres:11.2
