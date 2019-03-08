#!/usr/bin/env bash
# deploy.sh - push things to the production server.
# This file can be executed by travis or locally.

set -e

die() { echo "$*"; exit 1; }

ssh_opts="-o Port=359 -o User=bbs-backend -o StrictHostKeyChecking=no -o IdentityFile=travis/ssh-key"

if [ ! -f travis/ssh-key ];then
	openssl aes-256-cbc -K $encrypted_db197bbd43df_key -iv $encrypted_db197bbd43df_iv -in travis/ssh-key.enc -out travis/ssh-key -d
	chmod 600 travis/ssh-key
fi

eval "$(ssh-agent -s)"
trap 'eval "$(ssh-agent -ks)"' EXIT

case "$1" in
rust)
	bin=(backend/target/*/backend)
	bin="${bin[0]}"
	[ -f "$bin" ] || die "No $bin"

	rm -rf tmp
	mkdir tmp
	cp -lr -t tmp \
		$bin ./backend/migrations
	tar cz -C tmp . | ssh $ssh_opts hedlx.org '
		set -e
		rm -rf tmp/rust
		mkdir -p tmp/rust
		tar xzf - -C tmp/rust

		sudo systemctl stop bbs-backend

		mv tmp/rust/backend ./backend
		fail=
		~/.cargo/bin/diesel migration run \
			--database-url \
			postgres://bbs-backend@%2Fvar%2Frun%2Fpostgresql/bbs-staging \
			--migration-dir tmp/rust/migrations || fail=1

		sudo systemctl start bbs-backend

		sleep 1
		if systemctl is-active --quiet bbs-backend
		then echo Service is running
		else echo Service is not running; exit 1
		fi

		if [ "$fail" ]
		then echo "Migration failed"; exit 1
		fi
	'
	rm -rf tmp
	;;
elm)
	[ -f "front-elm/static/index.html" ] || die "No front-elm/static/index.html"

	# TODO move to ~/tmp/elm
	ssh -C $ssh_opts hedlx.org 'rm -rf front-elm.tmp'
	scp -C $ssh_opts -r front-elm/static hedlx.org:front-elm.tmp
	ssh -C $ssh_opts hedlx.org 'cd front-elm.tmp && mv index.html main.js favicon.ico /srv/www/bbs/elm/ && echo moved'
	;;
clojure)
	[ -f "./front/resources/public/index.html" ] || die "No front/resources/public/index.html"

	# TODO move to ~/tmp/clojure
	ssh -C $ssh_opts hedlx.org 'rm -rf front-clj.tmp'
	scp -C $ssh_opts -r front/resources/public hedlx.org:front-clj.tmp
	# TODO: atomic swap
	ssh -C $ssh_opts hedlx.org 'cd front-clj.tmp && rm -rf /srv/www/bbs/clj/* && mv * /srv/www/bbs/clj/ && echo moved'
	;;
*)
	echo Invalid parameters
	exit 1
esac
