use sha2::{Sha256, Digest};
use base64;

pub fn generate(s: String) -> String {
    let mut hasher = Sha256::new();
    hasher.input(s);
    base64::encode(&hasher.result().as_slice()[0..9])
}
