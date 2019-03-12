use super::error::Error;
use super::events::{validate_message, validate_thread};
use super::http_multipart::extract_file;
use super::image;
use super::limits::{Limits, LIMITS};
use data::{Config, FullThread, NewMessage, NewThread, ThreadPreview};
use db::Db;
use rocket::fairing::AdHoc;
use rocket::http::ContentType;
use rocket::{Data, State};
use rocket_contrib::json::{Json, JsonValue};
use std::path::PathBuf;
use tripcode::file_sha512;

#[get("/threads?<before>&<after>&<limit>&<tag>")]
fn threads_list(
    db: Db,
    before: Option<u32>, // timestamp
    after: Option<u32>,  // timestamp
    limit: Option<u32>,
    tag: Option<String>,
) -> Json<Vec<ThreadPreview>> {
    let limit = limit.unwrap_or(100);
    let resp = match (before, after) {
        (None, None) => db.get_threads_before(0, limit),
        (Some(ts), None) => db.get_threads_before(ts, limit),
        (None, Some(_)) => Vec::new(),
        (Some(_), Some(_)) => Vec::new(),
    };
    Json(resp)
}

#[get("/threads/<id>")]
fn thread_id(db: Db, id: i32) -> Option<Json<FullThread>> {
    db.get_thread(id).map(Json)
}

#[post("/threads", format = "json", data = "<thr>")]
fn thread_new(db: Db, thr: Json<NewThread>) -> Result<&'static str, Error> {
    let thr = validate_thread(thr.0)?;
    db.new_thread(thr);
    Ok("{}")
}

#[post("/threads/<id>", format = "json", data = "<msg>")]
fn thread_reply(
    db: Db,
    id: i32,
    msg: Json<NewMessage>,
) -> Result<Error, Error> {
    let msg = validate_message(msg.0)?;
    Ok(db.reply_thread(id, msg))
}

#[post("/upload", format = "multipart", data = "<data>")]
fn api_post_upload(
    db: Db,
    config: State<Config>,
    cont_type: &ContentType,
    data: Data,
) -> Result<JsonValue, Error> {
    let (_temp_dir, fname) = extract_file(cont_type, data, &config.tmp_dir)?;
    let hash = file_sha512(&fname).ok_or_else(|| Error::Upload("ok"))?;
    if !db.have_file(&hash) {
        let info = image::get_info(&fname)
            .ok_or_else(|| Error::Upload("Cant parse file"))?;
        let thumb_fname = image::make_thumb(&fname)
            .ok_or_else(|| Error::Upload("Cant generate_thumb"))?;

        std::fs::rename(fname, config.files_dir.join(&hash))
            .map_err(|_| Error::Upload("Can't rename"))?;
        std::fs::rename(thumb_fname, config.thumbs_dir.join(&hash))
            .map_err(|_| Error::Upload("Can't rename"))?;
        db.add_file(info, &hash);
    }
    Ok(json!({ "id": &hash }))
}

#[delete("/threads/<id>?<password>")]
fn api_delete_thread(db: Db, id: i32, password: String) -> Error {
    db.delete_thread(id, password)
}

#[delete("/threads/<id>/replies/<no>?<password>")]
fn api_delete_thread_reply(
    db: Db,
    id: i32,
    no: i32,
    password: String,
) -> Error {
    db.delete_message(id, no, password)
}

#[get("/limits")]
fn limits() -> Json<Limits> {
    Json(LIMITS)
}

pub fn start() {
    rocket::ignite()
        .attach(Db::fairing())
        .attach(AdHoc::on_attach("Config", |rocket| {
            let config = {
                let c = &rocket.config();
                Config {
                    tmp_dir: PathBuf::from(
                        c.get_str("tmp_dir").unwrap().to_string(),
                    ),
                    thumbs_dir: PathBuf::from(
                        c.get_str("thumbs_dir").unwrap().to_string(),
                    ),
                    files_dir: PathBuf::from(
                        c.get_str("files_dir").unwrap().to_string(),
                    ),
                }
            };
            Ok(rocket.manage(config))
        }))
        .mount(
            "/",
            routes![
                api_delete_thread,
                api_delete_thread_reply,
                api_post_upload,
                limits,
                thread_id,
                thread_new,
                thread_reply,
                threads_list,
            ],
        )
        .launch();
}
