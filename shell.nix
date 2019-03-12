let
  moz-overlay = import (builtins.fetchTarball https://github.com/mozilla/nixpkgs-mozilla/archive/master.tar.gz);
  nixpkgs = 
    import (builtins.fetchTarball {
      name = "nixos-unstable-2018-12-17";
      url = https://github.com/nixos/nixpkgs/archive/51deb8951d8910e2706a3c48d9765fc8d410d5f5.tar.gz;
      sha256 = "1mkg1g2hsr4rm6xqyh4v6xjfcllx1lgczc9gaw51n9h1lhxfj71k";
    }) {
      overlays = [ moz-overlay ];
    };
    rust-channel = nixpkgs.rustChannelOf { date = "2019-02-26"; channel = "nightly"; };
    rust-platform = (nixpkgs.makeRustPlatform {
      rustc = rust-channel.rust;
      cargo = rust-channel.cargo;
    }) // {
      rustcSrc = ''${rust-channel.rust-src}/lib/rustlib/src/rust/src'';
    };
in with nixpkgs;
stdenv.mkDerivation {
  name = "hedlx-bbs";
  RUST_SRC_PATH = ''${rust-channel.rust-src}/lib/rustlib/src/rust/src'';
  buildInputs = [
    rust-channel.rust
    rust-channel.rust-src

    (rustracer.override { rustPlatform = rust-platform; })

    postgresql.lib
    postgresql
    (callPackage ./nix/pgquarrel.nix { postgresql = postgresql_11; })

    # front-clj
    leiningen

    # front-elm
    nodejs-10_x
  ];
}
