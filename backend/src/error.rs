pub type Status = rocket::http::Status;
pub type Error = rocket::response::status::Custom<rocket_contrib::json::JsonValue>;
pub fn error(status: Status, message: &'static str, code: &'static str) -> Error {
    rocket::response::status::Custom(status, json!({"message": message, "code": code}))
}
