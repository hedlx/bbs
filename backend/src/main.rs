#![feature(proc_macro_hygiene, decl_macro)]

extern crate chrono;
extern crate postgres;
#[macro_use]
extern crate rocket;
#[macro_use]
extern crate rocket_contrib;
extern crate serde;

use rocket_contrib::json::Json;

mod data;
mod db;
use data::{Message, OutMessage, Thread};
use db::Db;

// TODO: multipart upload https://github.com/SergioBenitez/Rocket/issues/106

#[get("/threads?<before>&<after>&<limit>&<tag>")]
fn threads_list(
    db: Db,
    before: Option<u32>, // timestamp
    after: Option<u32>,  // timestamp
    limit: Option<u32>,
    tag: Option<String>,
) -> Json<Vec<Thread>> {
    let limit = limit.unwrap_or(100);
    let resp = match (before, after) {
        (None, None) => db.get_threads_before(0, limit),
        (Some(ts), None) => db.get_threads_before(ts, limit),
        (None, Some(_)) => Vec::new(),
        (Some(_), Some(_)) => Vec::new(),
    };
    Json(resp)
}

#[get("/threads/<id>?<before>&<after>&<limit>")]
fn thread_id(
    id: u32,
    before: Option<u32>, // message id
    after: Option<u32>,  // message id
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

#[post("/threads", format = "json", data = "<msg>")]
fn thread_new(db: Db, msg: Json<Message>) -> &'static str {
    db.new_thread(msg.0);
    "done"
}

#[post("/threads/<id>", format = "json", data = "<msg>")]
fn thread_reply(id: u32, msg: Json<Message>) -> &'static str {
    "123"
}

fn main() {
    rocket::ignite()
        .attach(Db::fairing())
        .mount(
            "/",
            routes![threads_list, thread_id, thread_new, thread_reply],
        )
        .launch();
}
