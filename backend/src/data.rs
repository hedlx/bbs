use serde::{Deserialize, Serialize};

#[derive(Deserialize)]
pub struct NewMessage {
    pub name: String,
    pub secret: String, // used to produce tripcode
    pub text: String,
}

#[derive(Serialize)]
pub struct Message {
    pub no: u32,
    pub name: String,
    pub trip: String,
    pub text: String,
}

#[derive(Serialize)]
pub struct Thread {
    pub id: u32,
    pub op: Message,
    pub last: Vec<Message>,
}
