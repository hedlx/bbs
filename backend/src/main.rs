#![feature(proc_macro_hygiene, decl_macro)]

extern crate base64;
extern crate chrono;
#[macro_use]
extern crate diesel;
extern crate postgres;
#[macro_use]
extern crate rocket;
#[macro_use]
extern crate rocket_contrib;
extern crate multipart;
extern crate serde;
extern crate serde_json;
extern crate sha2;
extern crate subprocess;

mod data;
mod db;
mod error;
mod events;
mod http;
mod http_multipart;
mod limits;
mod schema;
mod tripcode;

fn main() {
    self::http::start();
}
