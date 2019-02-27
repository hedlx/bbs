use rusqlite::types::ToSql;
use rusqlite::{Connection, NO_PARAMS};

pub struct Db {
    conn: Connection,
}

impl Db {
    pub fn new() -> Db {
        Db {
            conn: Connection::open_in_memory().unwrap(),
        }
    }

    pub fn init(&self) {
        self.conn
            .execute("
                CREATE TABLE messages (
                    id        INTEGER PRIMARY KEY,
                    thread_id INTEGER NOT NULL,     -- 0 for original posts, or `id` of OP

                    name      VARCHAR,
                    trip      VARCHAR,

                    sender   TEXT NOT NULL,         -- IP address or telegram id
                    message  TEXT,
                    ts       TIMESTAMP
                )",
                NO_PARAMS,
            )
            .unwrap();
    }
}
