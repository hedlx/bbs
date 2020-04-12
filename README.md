# Hedlx BBS
[![Build Status](https://travis-ci.org/hedlx/bbs.svg?branch=master)](https://travis-ci.org/hedlx/bbs)

An elegant message board software, for a more civilized age.

## Next generation backend

## Dependencies

1. docker
2. docker-compose

## Configuration

Create `.env` file in project root with next variable:
```bash
HASURA_SECRET=SUPER_HASURA_SECRET
```

### Development

To run service in development mode, just add next line to the `.env`:
```
DOCKERFILE=Dockerfile.dev
```

After that you be able to hot reload lambdas on code change.