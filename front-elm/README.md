# Unnamed Hedlx BBS Reader

This is a Hedlx BBS frontend.

## Setup

1. Install `npm`, `npx` and `git`
1. Clone this repository
1. Run `npm install` in the repository root directory
1. Change `serverUrl` in `src/Env.elm` to your back-end url.
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
- Try not to expose values on import. Prefer to use qualified names. Starting from ver. 0.19 elm compiler complains about variable shadowing.
Use `as` keyword to deal with long module names. Prefer to take as synonym the name of the deepest module. For example: `import Json.Encode as Encode`.
As an exception you can expose values when provider module functions form domain language for a client module. For example, feel free to import everything from `Html.Attributes` module in `View` modules.

    ##### Bad
    ```
    import Json.Encode exposing (..)
    ...
    ... encode 0 (string True) ...
    ...
    ```

    ##### Better
    ```
    import Json.Encode
    ...
    ... Json.Encode.encode 0 (Json.Encode.string True) ...
    ...
    ```

    ##### Acceptable
    ```
    import Json.Encode as JsonE
    ...
    ... JsonE.encode 0 (JsonE.string True) ...
    ...
    ```

    ##### Good
    ```
    import Json.Encode as Encode
    ...
    ... Encode.encode 0 (Encode.string True) ...
    ...
    ```
- In `View` modules use fully qualified names for model types.
    ##### Bad
    ```
        module View.Post exposing (view)
        import Model.Post as Post exposing (Post)
        ...
    ```
    ##### Good
    ```
        module View.Post exposing (view)
        import Model.Post
        ...
    ```

- Prefer to make a data type [opaque](https://package.elm-lang.org/help/design-guidelines) when a `set`/`update` function for this type exists.

- Put JSON decoders and encode functions into model modules. It will help to make a data type opaque if you need it. For example, `Model.Post` module should provide `decoder` and `empty` functions, such that:
    ```
    import Model.Post as Post exposing (Post)
    ...
    jsonToPost : Json.Encode.Value -> Post
    jsonToPost =
        Json.Decode.decodeValue Post.decoder
            >> Error.withDefault Post.empty
    ```

## Learn ELM
[Gentle Introduction](https://elmprogramming.com/)

[Elm Language Guide](https://guide.elm-lang.org/)

[Packages](https://package.elm-lang.org/)

[Elm Search (Hoogle-like search by function signature or name)](https://klaftertief.github.io/elm-search/)

