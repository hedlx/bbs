# Backend

*Run*:
```
cd backend
RUST_BACKTRACE=1 ROCKET_PORT=8001 ROCKET_ADDRESS=127.0.0.1 ROCKET_DATABASES='{db={url="postgres://postgres@127.0.0.1:5432"}}' cargo run
```

*Build:*
```
cd backend
cargo build
```

sudo rm -rf run/db-data # clean db (optional)
docker compose up

# Manual deploy:

Put your private ssh key to `travis/ssh-key`.
Add public key to `/home/bbs-backend/.ssh/authorized_keys`.

```
./travis/deploy.sh rust
./travis/deploy.sh elm
./travis/deploy.sh clojure
```
