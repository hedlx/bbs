# Unnamed Hedlx BBS Reader

This is a Hedlx BBS frontend.

## Setup

1. Install `npm`, `npx` and `git`
1. Clone this repository
1. Run `npm install` in the repository root directory
1. Change `urlServer` in `src/Env.elm` to your back-end url.
1. Run `npm run make` to compile application
1. Use a web server to serve files from `static` directory
1. Configure your web server to serve `static/index.html` on 404 errors
1. **Done!**

## Development

#### Getting Started

1. Install `npm`, `npx` and `git`
1. Clone this repository
1. Run `npm install` in the repository root directory
1. Run `npm run watch` to start live server
1. **⭐ Develop ⭐**

#### More

Compiling:
```
npm run make
```

Running elm commands:
```
npx elm <args>
```

For example, installing the `elm/json` package:

```
npx elm install elm/json
```

#### Rules & Conventions

- **Use [elm-format](https://github.com/avh4/elm-format) to format elm files**
    ```
    npx elm-format <file>
    ```

- Run [elm-analyse](https://github.com/stil4m/elm-analyse) and clean all messages before commit
    ```
    npm run analyse
    ```

## Learn ELM
[Gentle Introduction](https://elmprogramming.com/)

[Elm Language Guide](https://guide.elm-lang.org/)

[Packages](https://package.elm-lang.org/)

[Elm Search (Hoogle-like search by function signature or name)](https://klaftertief.github.io/elm-search/)

