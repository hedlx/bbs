#!/bin/sh
# deploy.sh - push backend binary to the production server.
# This file can be executed by travis or locally.

set -e

die() { echo "$*"; exit 1; }

bin=backend/target/debug/backend
ssh_opts="-o Port=359 -o User=bbs-backend -o StrictHostKeyChecking=no -o IdentityFile=travis/ssh-key"

[ -f "$bin" ] || die "No $bin"

if [ ! -f travis/ssh-key ];then
	openssl aes-256-cbc -K $encrypted_db197bbd43df_key -iv $encrypted_db197bbd43df_iv -in travis/ssh-key.enc -out travis/ssh-key -d
	chmod 600 travis/ssh-key
fi

eval "$(ssh-agent -s)"
scp -C $ssh_opts $bin hedlx.org:backend.new
scp -C $ssh_opts ./db/init/init.sql hedlx.org:init.sql.new
ssh $ssh_opts hedlx.org ./deploy.sh
eval "$(ssh-agent -ks)"
