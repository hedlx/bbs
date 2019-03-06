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
extern crate serde;
extern crate sha2;

mod data;
mod db;
mod events;
mod http;
mod schema;
mod tripcode;

fn main() {
    self::http::start();
}
