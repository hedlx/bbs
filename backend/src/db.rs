use super::data::{Message, OutMessage, Thread};
use chrono::{NaiveDateTime, Utc};
use postgres::{Connection, TlsMode};
use rocket_contrib::databases;

#[database("db")]
pub struct Db ( Connection );

impl Db {
    pub fn new_thread(&self, msg: Message) {
        let now = Utc::now().naive_utc();

        let thread_id: i32 = self.0
            .query(
                "
                    INSERT INTO threads(last_reply_no, bump)
                    VALUES (0, $1)
                    RETURNING id
                ",
                &[&now],
            )
            .unwrap()
            .get(0)
            .get(0);

        self.0
            .execute(
                "
                    INSERT INTO messages
                    ( thread_id, no, sender, text, ts )
                    VALUES (
                        $1, 0, 'sender', $2, $3
                    )
                ",
                &[&thread_id, &msg.text, &now],
            )
            .unwrap();
    }

    pub fn get_threads_before(&self, ts: u32, limit: u32) -> Vec<Thread> {
        let rows = self.0
            .query(
                "
                SELECT id, last_reply_no, bump
                  FROM threads
                 WHERE bump > $1
                 ORDER BY (bump, id) ASC
                 LIMIT $2
            ",
                &[&NaiveDateTime::from_timestamp(ts as i64, 0), &(limit as i64)],
            )
            .expect("get_threads_before");
        let mut result = Vec::new();
        for row in &rows {
            let id: i32 = row.get(0);
            let last_reply_no: i32 = row.get(1);
            let bump: NaiveDateTime = row.get(2);
            result.push(Thread {
                id: id as u32,
                op: self.get_op(id),
                last: Vec::new(),
            });
        }
        result
    }

    fn get_op(&self, thread_id: i32) -> OutMessage {
        let msg = self.0
            .query(
                "
                SELECT name, trip, text
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
}
