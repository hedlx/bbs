# front

This is the BBS frontend.


## Dependencies

* Java 12
* Node v12.11.1
* NVM (optional, helps to not mess around node versions)


## Deps installation

1. Install as usual `java` and `node` (if you are Rambo) or `nvm`.
2. Go to the `front`
2. For nvm additionally perform `nvm i && nvm use` to switch on the target version from `.nvmrc`. If you have installed node just chill out, you are cool :sunglasses:
3. Run `npm ci`


## Development mode

To start dev server:

```
npm run dev
```

In different terminal run:

```
npm run styles:watch
```

If this doc is up to date you can go to [http://localhost:8080](http://localhost:8080) otherwise take a look at `shadow-cljs.edn`


### Building for release

To make optimized build just run:

```
npm run build
```

After that you will have all necessary files in `resources/public/`
