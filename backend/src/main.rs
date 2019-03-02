#![feature(proc_macro_hygiene, decl_macro)]

extern crate chrono;
#[macro_use]
extern crate diesel;
extern crate postgres;
#[macro_use]
extern crate rocket;
#[macro_use]
extern crate rocket_contrib;
extern crate serde;

use rocket_contrib::json::Json;

mod data;
mod db;
mod schema;
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
    db: Db,
    id: i32,
    before: Option<u32>, // message id
    after: Option<u32>,  // message id
    limit: Option<u32>,
) -> Json<Vec<OutMessage>> {
    let limit = limit.unwrap_or(100);
    let msgs = match (before, after) {
        (None, None) => { db.get_thread(id) } // all threads
        (Some(_), None) => { Vec::new() }    // before
        (None, Some(_)) => { Vec::new() }    // after
        (Some(_), Some(_)) => { Vec::new() } // range / 400
    };
    Json(msgs)

    // TODO: return 404 if thread does not exists
}

#[post("/threads", format = "json", data = "<msg>")]
fn thread_new(db: Db, msg: Json<Message>) -> &'static str {
    db.new_thread(msg.0);
    "done"
}

#[post("/threads/<id>", format = "json", data = "<msg>")]
fn thread_reply(
    db: Db,
    id: i32,
    msg: Json<Message>,
) -> &'static str {
    if db.reply_thread(id, msg.0) {
        "done"
    } else {
        "no such thread"
        // TODO: 404 status code
    }
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
