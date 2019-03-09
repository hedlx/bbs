use super::data::{DbMessage, DbNewThread, DbThread, Message, NewMessage, NewThread, Thread};
use super::error::Error;
use chrono::{NaiveDateTime, Utc};
use diesel::sql_types::{Integer, Timestamp};
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

            let result = msg_to_db_msg(thr.msg, now, thread_id, 0);

            insert_into(super::schema::messages::dsl::messages)
                .values(&result)
                .execute(&self.0)?;

            Ok(db_msg_to_msg(result))
        })
        .unwrap()
    }

    pub fn reply_thread(&self, thread_id: i32, msg: NewMessage) -> Error {
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
                .values(&msg_to_db_msg(msg, now, thread_id, no))
                .execute(&self.0)?;

            Ok(Error::OK)
        })
        .unwrap()
    }

    pub fn get_threads_before(&self, ts: u32, limit: u32) -> Vec<Thread> {
        self.transaction(|| {
            let threads = sql_query(r"
                SELECT *
                  FROM threads
                 WHERE bump > $1
                 ORDER BY (bump, id) ASC
                 LIMIT $2
            ")
            .bind::<Timestamp, _>(NaiveDateTime::from_timestamp(ts as i64, 0))
            .bind::<Integer, _>(limit as i32)
            .load::<DbThread>(&self.0)?
            .into_iter()
            .map(|thread| Thread {
                id: thread.id as u32,
                subject: thread.subject,
                op: self.get_op(thread.id),
                last: self.get_last(thread.id).unwrap(),
            })
            .collect();
            Ok(threads)
        })
        .unwrap()
    }

    pub fn get_thread_messages(&self, thread_id: i32) -> Option<Vec<Message>> {
        self.transaction(|| {
            let messages = sql_query(r"
                SELECT *
                  FROM messages
                 WHERE thread_id = $1
            ")
            .bind::<Integer, _>(thread_id)
            .get_results::<DbMessage>(&self.0)?;

            let messages: Vec<Message> = messages.into_iter().map(db_msg_to_msg).collect();

            if messages.is_empty() {
                Ok(None)
            } else {
                Ok(Some(messages))
            }
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

    fn get_op(&self, thread_id: i32) -> Message {
        let op = sql_query(r"
            SELECT *
              FROM messages
             WHERE thread_id = $1
               AND no = 0
        ")
        .bind::<Integer, _>(thread_id)
        .get_result::<DbMessage>(&self.0)
        .unwrap();
        db_msg_to_msg(op)
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
            .map(db_msg_to_msg)
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

fn db_msg_to_msg(msg: DbMessage) -> Message {
    Message {
        no: msg.no as u32,
        name: msg.name,
        trip: msg.trip,
        text: msg.text,
        ts: msg.ts.timestamp(),
    }
}

fn msg_to_db_msg(msg: NewMessage, ts: NaiveDateTime, thread_id: i32, no: i32) -> DbMessage {
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
