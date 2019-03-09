// TODO: multipart upload https://github.com/SergioBenitez/Rocket/issues/106

use super::error::Error;
use super::events::{validate_message, validate_thread};
use super::limits::{Limits, LIMITS};
use data::{Message, NewMessage, NewThread, Thread};
use db::Db;
use rocket_contrib::json::Json;

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
) -> Option<Json<Vec<Message>>> {
    let limit = limit.unwrap_or(100);
    match (before, after) {
        (None, None) => db.get_thread_messages(id).map(Json),
        (Some(_), None) => None,    // before
        (None, Some(_)) => None,    // after
        (Some(_), Some(_)) => None, // range / 400
    }
}

#[post("/threads", format = "json", data = "<thr>")]
fn thread_new(db: Db, thr: Json<NewThread>) -> Result<&'static str, Error> {
    let thr = validate_thread(thr.0)?;
    db.new_thread(thr);
    Ok("{}")
}

#[post("/threads/<id>", format = "json", data = "<msg>")]
fn thread_reply(db: Db, id: i32, msg: Json<NewMessage>) -> Result<Error, Error> {
    let msg = validate_message(msg.0)?;
    Ok(db.reply_thread(id, msg))
}

#[delete("/threads/<id>?<password>")]
fn api_delete_thread(db: Db, id: i32, password: String) -> Error {
    db.delete_thread(id, password)
}

#[delete("/threads/<id>/replies/<no>?<password>")]
fn api_delete_thread_reply(db: Db, id: i32, no: i32, password: String) -> Error {
    db.delete_message(id, no, password)
}

#[get("/limits")]
fn limits() -> Json<Limits> {
    Json(LIMITS)
}

pub fn start() {
    rocket::ignite()
        .attach(Db::fairing())
        .mount(
            "/",
            routes![
                api_delete_thread,
                api_delete_thread_reply,
                limits,
                thread_id,
                thread_new,
                thread_reply,
                threads_list,
            ],
        )
        .launch();
}
