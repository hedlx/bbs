use base64;
use sha2::{Digest, Sha256};
use std::path::PathBuf;

pub fn generate(s: String) -> String {
    let mut hasher = Sha256::new();
    hasher.input(s);
    base64::encode(&hasher.result().as_slice()[0..9])
}

pub fn file_sha512(fname: &PathBuf) -> Option<String> {
    let mut f = std::fs::File::open(fname).ok()?;
    let mut sha = sha2::Sha512::new();
    std::io::copy(&mut f, &mut sha).ok()?;
    Some(
        base64::encode(&sha.result().as_slice())
            .chars()
            .filter_map(|x| match x {
                '+' => Some('-'),
                '/' => Some('_'),
                '=' => None,
                x => Some(x),
            })
            .collect::<String>(),
    )
}
