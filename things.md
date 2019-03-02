Run backend:

```
sudo rm -rf db/data # clean db (optional)
./db/run.sh         # run postgres
cd backend
RUST_BACKTRACE=1 ROCKET_DATABASES='{db={url="postgres://postgres@127.0.0.1:5432"}}' cargo run
```

Curl queries:

```
curl localhost:8000/threads --header "Content-Type: application/json" --request POST --data '{"name":"me", "secret":"x", "text":"nope"}'
curl localhost:8000/threads'
```