#!/bin/sh


build-rust)
	cd backend; RUST_BACKTRACE=1 ROCKET_PORT=8001 ROCKET_ADDRESS=127.0.0.1 ROCKET_DATABASES='{db={url="postgres://postgres@127.0.0.1:5432"}}' cargo build
	;;
build-elm)
	cd front-elm; npm run make;;
build-clj)
	cd front; lein cljsbuild once min;;
remove-db)
	sudo rm -rf run/db/data;;
run-serv)
	docker-compose --up
