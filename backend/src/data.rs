use chrono::NaiveDateTime;
use serde::{Deserialize, Serialize};
use super::schema::{messages, threads};

/* REST-related */

#[derive(Deserialize)]
pub struct NewMessage {
    pub name: Option<String>,
    pub secret: Option<String>, // used to produce tripcode
    pub password: Option<String>, // used to delete
    pub text: String,
}

#[derive(Serialize)]
pub struct Message {
    pub no: u32,
    pub name: String,
    pub trip: String,
    pub text: String,
    pub ts: i64,
}

#[derive(Serialize)]
pub struct Thread {
    pub id: u32,
    pub op: Message,
    pub last: Vec<Message>,
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
}

#[derive(QueryableByName)]
#[table_name = "threads"]
pub struct DbThread {
    pub id: i32,
    pub last_reply_no: i32,
    pub bump: NaiveDateTime,
}

#[derive(Insertable)]
#[table_name = "threads"]
pub struct DbNewThread {
    pub last_reply_no: i32,
    pub bump: NaiveDateTime,
}
