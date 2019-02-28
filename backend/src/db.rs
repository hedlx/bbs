use postgres::{Connection, TlsMode};

use super::data::{Message, OutMessage};

pub struct Db {
    conn: Connection,
}

impl Db {
    pub fn new() -> Db {
        Db {
            conn: Connection::connect("postgres://postgres@127.0.0.1:5432", TlsMode::None).unwrap(),
        }
    }

    pub fn init(&self) {
    }
}
