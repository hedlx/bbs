use super::schema::{messages, threads};
use chrono::NaiveDateTime;
use serde::{Deserialize, Serialize};

/* REST-related */

#[derive(Deserialize)]
pub struct NewMessage {
    pub name: Option<String>,
    pub secret: Option<String>,   // used to produce tripcode
    pub password: Option<String>, // used to delete
    pub text: String,
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
    pub text: String,
    pub ts: i64,
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

/* DB-related */

#[derive(QueryableByName, Insertable, Queryable)]
#[table_name = "messages"]
pub struct DbMessage {
    pub thread_id: i32,
    pub no: i32,
    pub name: Option<String>,
    pub trip: Option<String>,
    pub sender: String,
    pub text: String,
    pub ts: NaiveDateTime,
    pub password: Option<String>,
}

#[derive(QueryableByName)]
#[table_name = "threads"]
pub struct DbThread {
    pub id: i32,
    pub last_reply_no: i32,
    pub subject: Option<String>,
    pub bump: NaiveDateTime,
}

#[derive(Insertable)]
#[table_name = "threads"]
pub struct DbNewThread {
    pub last_reply_no: i32,
    pub subject: Option<String>,
    pub bump: NaiveDateTime,
}
