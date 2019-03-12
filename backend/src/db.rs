use super::data::{
    DbFile,
    DbMessage,
    DbNewThread,
    DbThread,
    File,
    FullThread,
    Message,
    NewMessage,
    NewThread,
    ThreadPreview
};
use super::http_multipart::MediaFile1;
use super::error::Error;
use base64;
use chrono::{NaiveDateTime, Utc};
use diesel::sql_types::{Integer, BigInt, Timestamp};
use diesel::Connection;
use diesel::ExpressionMethods;
use diesel::OptionalExtension;
use diesel::QueryDsl;
use diesel::QueryResult;
use diesel::RunQueryDsl;
use diesel::{insert_into, delete, sql_query};
use rocket_contrib::databases::diesel;

#[database("db")]
pub struct Db(diesel::PgConnection);

#[derive(QueryableByName)]
struct Id {
    #[sql_type = "Integer"]
    id: i32,
}

#[derive(QueryableByName)]
struct Count {
    #[sql_type = "BigInt"]
    count: i64,
}

impl Db {
    /* NB: public methods must be wrapped in transactions. */

    pub fn new_thread(&self, thr: NewThread) -> Message {
        let now = Utc::now().naive_utc();

        self.transaction(|| {
            let thread_id = insert_into(super::schema::threads::dsl::threads)
                .values(&DbNewThread {
                    last_reply_no: 0,
                    subject: thr.subject,
                    bump: now,
                })
                .returning(super::schema::threads::dsl::id)
                .get_result(&self.0)?;

            let result = msg_to_db(thr.msg, now, thread_id, 0);

            insert_into(super::schema::messages::dsl::messages)
                .values(&result)
                .execute(&self.0)?;

            Ok(msg_from_db(result))
        })
        .unwrap()
    }

    pub fn reply_thread(
        &self,
        thread_id: i32,
        msg: NewMessage,
        files: Vec<MediaFile1>,
    ) -> Error {
        let now = Utc::now().naive_utc();

        self.transaction(|| {
            let no = sql_query(r"
                UPDATE threads
                   SET last_reply_no = last_reply_no+1,
                       bump = $1
                 WHERE id = $2
             RETURNING last_reply_no as id
            ")
            .bind::<Timestamp, _>(now)
            .bind::<Integer, _>(thread_id)
            .get_result::<Id>(&self.0)
            .optional()?;

            let no = match no {
                Some(no) => no.id,
                None => return Ok(Error::ThrNotFound),
            };

            insert_into(super::schema::messages::dsl::messages)
                .values(&msg_to_db(msg, now, thread_id, no))
                .execute(&self.0)?;

            insert_into(super::schema::files::dsl::files)
                .values(files
                        .into_iter()
                        .enumerate()
                        .map(|(fno, file)|file_to_db(file, thread_id, no, fno))
                        .collect::<Vec<DbFile>>())
                .execute(&self.0)?;
            Ok(Error::OK)
        })
        .unwrap()
    }

    pub fn get_threads_before(&self, ts: u32, limit: u32) -> Vec<ThreadPreview> {
        self.transaction(|| {
            let threads = sql_query(r"
                SELECT t.*, op.*,
                       (SELECT COUNT(*) FROM messages AS m WHERE m.thread_id = t.id)
                  FROM threads as t
                       LEFT JOIN messages AS op  ON t.id = op.thread_id
                 WHERE t.bump > $1
                   AND op.no = 0
                 ORDER BY (bump, id) ASC
                 LIMIT $2
            ")
            .bind::<Timestamp, _>(NaiveDateTime::from_timestamp(ts as i64, 0))
            .bind::<Integer, _>(limit as i32)
            .load::<(DbThread, DbMessage, Count)>(&self.0)?
            .into_iter()
            .map(|(thread, op, total)| {
                let last = self.get_last(thread.id).unwrap();
                let omitted = total.count as i32 - last.len() as i32 - 1;
                ThreadPreview {
                    id: thread.id as u32,
                    subject: thread.subject,
                    bump: thread.bump.timestamp(),
                    op: msg_from_db(op),
                    last: last,
                    omitted: omitted,
                }
            })
            .collect();
            Ok(threads)
        })
        .unwrap()
    }

    pub fn get_thread(&self, thread_id: i32) -> Option<FullThread> {
        self.transaction(|| {
            use super::schema::threads::dsl as d;
            let thread = d::threads
                .filter(d::id.eq(thread_id))
                .get_result::<DbThread>(&self.0)
                .optional()?;

            let thread = match thread {
                Some(thread) => thread,
                None => return Ok(None),
            };

            Ok(Some(FullThread {
                subject: thread.subject,
                messages: self.get_thread_messages(thread_id)?,
            }))
        }).unwrap()
    }

    pub fn delete_message(&self, thread_id: i32, no: i32, password: String) -> Error {
        self.transaction(|| {
            use super::schema::messages::dsl as d;
            let message = d::messages
                .filter(d::thread_id.eq(thread_id))
                .filter(d::no.eq(no))
                .get_result::<DbMessage>(&self.0)
                .optional()?;

            let message = match message {
                Some(message) => message,
                None => return Ok(Error::MsgNotFound),
            };

            if message.password != Some(password) {
                return Ok(Error::MsgBadPwd)
            }

            // TODO: simplify to `delete(message)`
            delete(
                d::messages
                .filter(d::thread_id.eq(thread_id))
                .filter(d::no.eq(no))
            ).execute(&self.0)?;

            Ok(Error::OK)
        }).unwrap()
    }

    pub fn delete_thread(&self, _thread_id: i32, _password: String) -> Error {
        Error::NotImpl
    }

    /* Private methods. */

    pub fn get_thread_messages(&self, thread_id: i32) -> QueryResult<Vec<Message>> {
        let messages = sql_query(r"
            SELECT *
              FROM messages
                   LEFT JOIN files
                          ON msg_no = no
                         AND msg_thread_id = $1
             WHERE thread_id = $1
             ORDER BY no, fno
        ")
        .bind::<Integer, _>(thread_id)
        .get_results::<(DbMessage, Option<DbFile>)>(&self.0)?;

        let mut result: Vec<Message> = Vec::new();
        for (msg, file) in messages {
            let is_same = match &result.last() {
                Some(last) if last.no == msg.no as u32 => true,
                _ => false,
            };
            if !is_same {
                result.push(msg_from_db(msg));
            }
            if let Some(file) = file {
                result.last_mut().unwrap().media.push(file_from_db(file));
            }
        }
        Ok(result)
    }

    fn get_last(&self, thread_id: i32) -> QueryResult<Vec<Message>> {
        use super::schema::messages::dsl as d;
        let mut result : Vec<Message> = d::messages
            .filter(d::thread_id.eq(thread_id))
            .filter(d::no.gt(0))
            .order(d::no.desc())
            .limit(5)
            .get_results::<DbMessage>(&self.0)?
            .into_iter()
            .map(msg_from_db)
            .collect();
        result.reverse();
        Ok(result)
    }

    fn transaction<T, F>(&self, f: F) -> Result<T, diesel::result::Error>
    where
        F: FnOnce() -> Result<T, diesel::result::Error>,
    {
        self.0.transaction::<_, diesel::result::Error, _>(f)
    }
}

fn msg_from_db(msg: DbMessage) -> Message {
    Message {
        no: msg.no as u32,
        name: msg.name,
        trip: msg.trip,
        text: msg.text,
        ts: msg.ts.timestamp(),
        media: Vec::new(),
    }
}

fn msg_to_db(msg: NewMessage, ts: NaiveDateTime, thread_id: i32, no: i32) -> DbMessage {
    DbMessage {
        thread_id: thread_id,
        no: no,
        name: msg.name,
        trip: msg.secret.map(super::tripcode::generate),
        password: msg.password,
        sender: String::new(),
        text: msg.text,
        ts: ts,
    }
}

fn file_from_db(file: DbFile) -> File {
    File {
        fname:     file.fname,
        size:      file.size,
        width:     file.width,
        height:    file.height,
        thumbnail: file.thumb.map(jpeg_to_data_base64),
    }
}

fn jpeg_to_data_base64(jpeg: Vec<u8>) -> String {
    format!("data:image/jpeg;base64,{}", base64::encode(jpeg.as_slice()))
}

fn file_to_db(
    file: MediaFile1,
    thread_id: i32, msg_no: i32, fno: usize,
) -> DbFile {
    let extension = match file.path.extension() {
        Some(x) => format!(".{}", x.to_str().unwrap()),
        None => String::new()
    };
    DbFile {
        msg_thread_id: thread_id,
        msg_no: msg_no,
        fno: fno as i16,

        fname: format!("/i/{}_{}_{}{}", thread_id, msg_no, fno, extension),
        size: file.size,
        width: file.width,
        height: file.height,

        thumb: file.thumb,
    }
}
