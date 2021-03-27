let
  moz-overlay = import (builtins.fetchTarball https://github.com/mozilla/nixpkgs-mozilla/archive/master.tar.gz);
  nixpkgs = 
    import (builtins.fetchTarball {
      name = "nixos-unstable-2020-02-16";
      url = https://github.com/nixos/nixpkgs/archive/56c4800e7f9d57b102bb53326f24c10847cec8a1.tar.gz;
      sha256 = "0r6fwzxs9ywhff8mp6hx2a1bzp8pwkc5qy3fv03i1k37rfabq4r8";
    }) {
      overlays = [ moz-overlay ];
    };
    rust-channel = nixpkgs.rustChannelOf { date = "2021-03-27"; channel = "nightly"; };
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

    imagemagick7
    pngcrush
    pngnq

    rustracer
    cargo-edit

    postgresql.lib
    postgresql
    (callPackage ./nix/pgquarrel.nix { postgresql = postgresql_11; })

    # front-clj
    leiningen

    # front-elm
    nodejs-10_x
  ];
}
