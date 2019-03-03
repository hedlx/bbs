#!/bin/sh
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
	bin=backend/target/debug/backend
	[ -f "$bin" ] || die "No $bin"

	scp -C $ssh_opts $bin hedlx.org:backend.new
	scp -C $ssh_opts ./db/init/init.sql hedlx.org:init.sql.new
	ssh $ssh_opts hedlx.org ./deploy.sh
	;;
elm)
	[ -f "front-elm/static/index.html" ] || die "No front-elm/static/index.html"

	ssh -C $ssh_opts hedlx.org 'rm -rf front-elm.tmp'
	scp -C $ssh_opts -r front-elm/static hedlx.org:front-elm.tmp
	ssh -C $ssh_opts hedlx.org 'cd front-elm.tmp && mv index.html main.js /srv/www/bbs/elm/ && echo copied'
	;;
*)
	echo Invalid parameters
	exit 1
esac
