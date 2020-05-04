# Hedlx BBS
[![Build Status](https://travis-ci.org/hedlx/bbs.svg?branch=master)](https://travis-ci.org/hedlx/bbs)

An elegant message board software, for a more civilized age.

## Next generation backend

## Dependencies

1. docker
2. docker-compose

## Configuration

Create `.env` file in project root with next variable, currently config suppots next variables (defauls):
```bash
HASURA_SECRET=SUPER_HASURA_SECRET
DOCKERFILE=Dockerfile

MINIO_ACCESS_KEY=MINIO_ACCESS_KEY
MINIO_SECRET_KEY=MINIO_SECRET_KEY
MINIO_BUCKET=MINIO_BUCKET
```

### Development

To run service in development mode, just add next line to the `.env`:
```bash
DOCKERFILE=Dockerfile.dev
```

After that you be able to hot reload lambdas on code change.

### Running

In general, you just need to set `docker-compose` on `stack.yml` file.
You can perform all docker-compose flows as usual.

For instance, to just launch containers perform:
```bash
docker-compose -f stack.yml up
```

In case you building prod version and api services have got changed, you proabably need to
additionally force `docker-compose` to rebuild images:

```bash
docker-compose -f stack.yml build
```