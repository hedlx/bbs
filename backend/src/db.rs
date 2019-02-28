use super::data::{Message, OutMessage, Thread};
use super::schema;
use chrono::Utc;
use postgres::{Connection, TlsMode};

use rocket_contrib::databases::diesel;
use diesel::sql_query;
use diesel::RunQueryDsl;
use diesel::sql_types::{Integer, Text};

#[database("db")]
pub struct Db ( diesel::PgConnection );

#[derive(QueryableByName)]
struct Id {
    #[sql_type = "Integer"]
    id: i32,
}

impl Db {
    pub fn new_thread(&self, msg: Message) {
        let now = Utc::now().naive_utc().timestamp();

        let thread_id = sql_query("
            INSERT INTO threads(last_reply_no, bump)
            VALUES (0, $1)
            RETURNING id
        ")
            .bind::<Integer, _>(now)
            .get_result::<Id>(&self.0).unwrap().id;

        sql_query("
            INSERT INTO messages
            ( thread_id, no, sender, text, ts
            VALUES (
                $1, 0, 'sender', $2, $3
            )
        ")
            .bind::<Integer, _>(thread_id)
            .bind::<Text, _>(msg.text)
            .bind::<Integer, _>(now)
            .execute(&self.0).unwrap();
    }

    pub fn get_threads_before(&self, ts: u32, limit: u32) -> Vec<Thread> {
        /*
        let rows = self
            .conn
            .query(
                "
                SELECT id, last_reply_no, bump
                  FROM threads
                 WHERE bump > $1
                 ORDER BY (bump, id) ASC
                 LIMIT $2
            ",
                &[&ts, &limit],
            )
            .unwrap();
        let mut result = Vec::new();
        for row in &rows {
            let id: u32 = row.get(0);
            let last_reply_no: u32 = row.get(1);
            let bump: u32 = row.get(2);
            result.push(Thread {
                id: id,
                op: self.get_op(id),
                last: Vec::new(),
            });
        }
        result
        */
        Vec::new()
    }

    /*
    fn get_op(&self, thread_id: u32) -> OutMessage {
        let msg = self
            .conn
            .query(
                "
                SELECT name, trip, 
                  FROM messages
                 WHERE thread_id = $1
                   AND no = 0
                ",
                &[&thread_id],
            )
            .unwrap();
        let msg = msg.get(0);
        OutMessage {
            no: 0,
            name: msg
                .get::<usize, Option<String>>(0)
                .unwrap_or("Anonymous".to_string()),
            trip: msg
                .get::<usize, Option<String>>(1)
                .unwrap_or("".to_string()),
            text: msg.get(2),
        }
    }
    */
}
