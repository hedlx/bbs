use super::schema::{attachments, files, messages, threads};
use chrono::NaiveDateTime;
use serde::{Deserialize, Serialize};
use std::path::PathBuf;

pub struct Config {
    pub tmp_dir: PathBuf,
    pub thumbs_dir: PathBuf,
    pub files_dir: PathBuf,
}

/* REST-related */

#[derive(Deserialize)]
pub struct NewMessage {
    pub name: Option<String>,
    pub secret: Option<String>, // used to produce tripcode
    pub password: Option<String>, // used to delete
    pub text: Option<String>,
    #[serde(default = "Vec::new")]
    pub media: Vec<NewAttachment>,
}

#[derive(Deserialize)]
pub struct NewAttachment {
    pub id: String,
    pub orig_name: String,
}

#[derive(Deserialize)]
pub struct NewThread {
    pub subject: Option<String>,
    #[serde(flatten)]
    pub msg: NewMessage,
}

#[derive(Serialize)]
pub struct Message {
    pub no: u32,
    pub name: Option<String>,
    pub trip: Option<String>,
    pub text: Option<String>,
    pub ts: i64,
    pub media: Vec<File>,
}

#[derive(Serialize)]
pub struct File {
    pub id: String,
    pub type_: String,
    pub orig_name: String,
    pub size: i32,
    pub width: i32,
    pub height: i32,
}

#[derive(Serialize)]
pub struct ThreadPreview {
    pub id: u32,
    pub subject: Option<String>,
    pub bump: i64,

    pub op: Message,
    pub last: Vec<Message>,
    pub omitted: i32,
}

#[derive(Serialize)]
pub struct Threads {
    pub count: i64,
    pub threads: Vec<ThreadPreview>,
}

#[derive(Serialize)]
pub struct FullThread {
    pub subject: Option<String>,
    pub messages: Vec<Message>,
}

/* DB-related */

#[derive(QueryableByName, Insertable, Queryable)]
#[table_name = "messages"]
pub struct DbMessage {
    pub thread_id: i32,
    pub no: i32,
    pub name: Option<String>,
    pub trip: Option<String>,
    pub sender: String,
    pub text: Option<String>,
    pub ts: NaiveDateTime,
    pub password: Option<String>,
}

#[derive(QueryableByName, Queryable)]
#[table_name = "threads"]
pub struct DbThread {
    pub id: i32,
    pub last_reply_no: i32,
    pub bump: NaiveDateTime,
    pub subject: Option<String>,
}

#[derive(Insertable, QueryableByName, Queryable)]
#[table_name = "files"]
pub struct DbFile {
    pub sha512: String,
    pub type_: i16,
    pub size: i32,
    pub width: i32,
    pub height: i32,
}

#[derive(Insertable, QueryableByName, Queryable)]
#[table_name = "attachments"]
pub struct DbAttachment {
    pub msg_thread_id: i32,
    pub msg_no: i32,
    pub fno: i16,
    pub orig_name: String,
    pub file_sha512: String,
}

#[derive(Insertable)]
#[table_name = "threads"]
pub struct DbNewThread {
    pub last_reply_no: i32,
    pub subject: Option<String>,
    pub bump: NaiveDateTime,
}
