use super::data::{NewMessage, Message, Thread, DbMessage, DbThread, DbNewThread};
use super::schema::{messages, threads};
use chrono::{NaiveDateTime, Utc};

use diesel::Connection;
use diesel::ExpressionMethods;
use diesel::OptionalExtension;
use diesel::QueryDsl;
use diesel::QueryResult;
use diesel::RunQueryDsl;
use diesel::sql_types::{Integer, Text, Timestamp};
use diesel::{insert_into, sql_query};
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

    pub fn new_thread(&self, msg: NewMessage) -> Message {
        let now = Utc::now().naive_utc();

        self.transaction(|| {
            let thread_id =
            insert_into(super::schema::threads::dsl::threads).values(
                &DbNewThread{
                    last_reply_no: 0,
                    bump: now,
                })
                .returning(super::schema::threads::dsl::id)
                .get_result(&self.0)?;

            let result = msg_to_db_msg(msg, now, thread_id, 0);

            insert_into(super::schema::messages::dsl::messages)
                .values(&result)
                .execute(&self.0)?;

            Ok(db_msg_to_msg(result))
        }).unwrap()
    }

    pub fn reply_thread(&self, thread_id: i32, msg: NewMessage) -> bool {
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
                None => return Ok(false),
            };

            insert_into(super::schema::messages::dsl::messages)
                .values(&msg_to_db_msg(msg, now, thread_id, no))
                .execute(&self.0)?;

            Ok(true)
        }).unwrap()
    }

    pub fn get_threads_before(&self, ts: u32, limit: u32) -> Vec<Thread> {
        self.transaction(|| {
            let threads = sql_query(r"
                SELECT id, last_reply_no, bump
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
                op: self.get_op(thread.id),
                last: self.get_last(thread.id).unwrap(),
            })
            .collect();
            Ok(threads)
        }).unwrap()
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
        db_msg_to_msg( op )
    }

    fn get_last(&self, thread_id: i32) -> QueryResult<Vec<Message>> {
        use super::schema::messages::dsl as d;
        let result = d::messages
            .filter(d::thread_id.eq(thread_id))
            .filter(d::no.gt(0))
            .limit(5)
            .get_results::<DbMessage>(&self.0)?
            .into_iter()
            .map(db_msg_to_msg)
            .collect();
        Ok(result)
    }

    pub fn get_thread_messages(
        &self,
        thread_id: i32,
    ) -> Option<Vec<Message>> {
        let messages = sql_query(r"
            SELECT *
              FROM messages
             WHERE thread_id = $1
        ")
        .bind::<Integer, _>(thread_id)
        .get_results::<DbMessage>(&self.0)
        .unwrap();

        let messages: Vec<Message> = messages
            .into_iter()
            .map(db_msg_to_msg)
            .collect();

        if messages.is_empty() {
            None
        } else {
            Some(messages)
        }
    }

    fn transaction<T, F>(&self, f: F) -> Result<T, diesel::result::Error>
    where F: FnOnce() -> Result<T, diesel::result::Error>,
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
    DbMessage{
        thread_id: thread_id,
        no: no,
        name: trim(msg.name),
        trip: trim(msg.secret).map(super::tripcode::generate),
        sender: String::new(),
        text: msg.text,
        ts: ts,
    }
}

fn trim(a: Option<String>) -> Option<String> {
    a.map(|s|s.trim().to_owned()).filter(|s|!s.is_empty())
}
