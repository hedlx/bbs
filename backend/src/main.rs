#![feature(proc_macro_hygiene, decl_macro)]

#[macro_use] extern crate rocket;
extern crate rocket_contrib;
extern crate serde;

use rocket_contrib::json::Json;
use serde::Deserialize;

// TODO: multipart upload https://github.com/SergioBenitez/Rocket/issues/106

#[derive(Deserialize)]
struct Message {
    name: String,
    trip: String,
    text: String,
}

#[get("/thread/list?<page>&<tag>")]
fn threads_list(page: Option<u8>, tag: Option<String>) -> &'static str {
    "Hello, world!"
}

#[get("/thread/<id>")]
fn thread_id(id: u32) -> &'static str {
    "Hello, world!"
}

#[post("/thread/new", format="json", data="<msg>")]
fn thread_new(msg: Json<Message>) -> &'static str {
    "Hello, world!"
}

#[post("/thread/<id>/reply", format="json", data="<msg>")]
fn thread_reply(id: u32, msg: Json<Message>) -> &'static str {
    "Hello, world!"
}

fn main() {
    rocket::ignite().mount("/", routes![threads_list, thread_id]).launch();
}
