#![feature(proc_macro_hygiene, decl_macro)]

#[macro_use]
extern crate rocket;
extern crate rocket_contrib;
extern crate rusqlite;
extern crate serde;

use rocket_contrib::json::Json;
use serde::{Deserialize, Serialize};

mod db;
use db::{Db};

// TODO: multipart upload https://github.com/SergioBenitez/Rocket/issues/106

#[derive(Deserialize)]
struct Message {
    name: String,
    secret: String, // used to produce tripcode
    text: String,
}

#[derive(Serialize)]
struct OutMessage {
    id: u32,
    name: String,
    trip: String,
    text: String,
}

#[get("/thread/list?<page>&<tag>")]
fn threads_list(page: Option<u8>, tag: Option<String>) -> &'static str {
    "Hello, world!"
}

#[get("/thread/<id>?<before>&<after>&<limit>")]
fn thread_id(
    id: u32,
    before: Option<u32>,
    after: Option<u32>,
    limit: Option<u32>,
) -> Json<Vec<OutMessage>> {
    let limit = limit.unwrap_or(100);
    match (before, after) {
        (None, None) => {}       // latest elements
        (Some(_), None) => {}    // before
        (None, Some(_)) => {}    // after
        (Some(_), Some(_)) => {} // range / 400
    }
    Json(vec![])
}

#[post("/thread/new", format = "json", data = "<msg>")]
fn thread_new(msg: Json<Message>) -> &'static str {
    "Hello, world!"
}

#[post("/thread/<id>/reply", format = "json", data = "<msg>")]
fn thread_reply(id: u32, msg: Json<Message>) -> &'static str {
    "Hello, world!"
}

fn main() {
    let db = Db::new();
    db.init();

    rocket::ignite()
        .mount(
            "/",
            routes![threads_list, thread_id, thread_new, thread_reply],
        )
        .launch();
}
