use serde::{Deserialize, Serialize};

#[derive(Deserialize)]
pub struct Message {
    name: String,
    secret: String, // used to produce tripcode
    text: String,
}

#[derive(Serialize)]
pub struct OutMessage {
    id: u32,
    name: String,
    trip: String,
    text: String,
}

