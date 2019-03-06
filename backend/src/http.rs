// TODO: multipart upload https://github.com/SergioBenitez/Rocket/issues/106

use rocket_contrib::json::Json;
use rocket::http::{Status, ContentType};
use serde::Serialize;
use super::events::validate_message;

use data::{NewMessage, Message, Thread};
use db::Db;

type Error = rocket::response::status::Custom<rocket_contrib::json::JsonValue>;
fn error(status: Status, text: &'static str, code: &'static str) -> Error {
    rocket::response::status::Custom(
        status,
        json!({"error": {"text": text, "code": code}}),
    )
}

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
        (None, None) => {
            db.get_thread_messages(id).map(Json)
        }
        (Some(_), None) => { None }    // before
        (None, Some(_)) => { None }    // after
        (Some(_), Some(_)) => { None } // range / 400
    }
}

#[post("/threads", format = "json", data = "<msg>")]
fn thread_new(db: Db, msg: Json<NewMessage>) -> Result<&'static str, Error> {
    let msg = validate_message(msg.0)
        .map_err(|(e,c)| error(Status::BadRequest, e, c))?;
    db.new_thread(msg);
    Ok("{}")
}

#[post("/threads/<id>", format = "json", data = "<msg>")]
fn thread_reply(
    db: Db,
    id: i32,
    msg: Json<NewMessage>,
) -> Result<&'static str, Error> {
    let msg = validate_message(msg.0)
        .map_err(|(e,c)| error(Status::BadRequest, e, c))?;
    if db.reply_thread(id, msg) {
        Ok("{}")
    } else {
        Err(error(Status::NotFound, "No such thread.", "thread.not_found"))
    }
}

#[delete("/threads/<id>/replies/<no>")]
fn thread_reply_delete(
    db: Db,
    id: i32,
    no: i32,
) -> Option<&'static str> {
    Some("NIY")
}

pub fn start() {
    rocket::ignite()
        .attach(Db::fairing())
        .mount(
            "/",
            routes![
                thread_id,
                thread_new,
                thread_reply,
                thread_reply_delete,
                threads_list,
            ],
        )
        .launch();
}
