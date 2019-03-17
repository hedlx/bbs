use rocket::http::Status;
use rocket::request::Request;
use rocket::response::status::Custom;
use rocket::response::{self, Responder};
use rocket_contrib::json::JsonValue;

fn code_to_err(code: u16) -> Status {
    match code {
        200 => Status::Ok,
        400 => Status::BadRequest,
        404 => Status::NotFound,
        401 => Status::Unauthorized,
        501 => Status::NotImplemented,
        _ => panic!(),
    }
}

macro_rules! def_errors {
    (
        $( $name:ident ($http_code:expr, $code:expr, $message:expr), )*
    ) => {
        #[derive(Debug)]
        pub enum Error {
            OK,
            Upload(&'static str),
            $( $name, )*
        }

        fn error2(err: Error) -> Custom<JsonValue> {
            match err {
                Error::OK => Custom(Status::Ok, json!({})),
                Error::Upload(x) =>
                    Custom(
                        Status::BadRequest,
                        json!({"debug": x, "code": "upload"})
                    ),
                $( Error::$name =>
                   Custom(
                       code_to_err($http_code),
                       json!({"message": $message, "code": $code }),
                    ),
                )*
            }
        }
    }
}

impl<'r> Responder<'r> for Error {
    fn respond_to(self, req: &Request) -> response::Result<'r> {
        error2(self).respond_to(req)
    }
}

def_errors! {
    MsgSubjLong(400, "message.subject_long", "Subject is too long."),
    MsgTextEmpt(400, "message.text_empty",   "Text should not be empty."),
    MsgTextLong(400, "message.text_long",    "Text should be no more than 4096 characters long."),
    MsgNameLong(400, "message.name_long",    "Name should be no more than 32 characters long."),
    MsgMediaCount(400, "message.media.count", "Too many mediafiles."),
    MsgMediaNameLong(400, "message.orig_name_long", "Media filename is too long."),
    MsgMediaNotFound(400, "message.media.id", "Media id not found"),

    MediaFileSize(400, "media.file_size", "Media file size is too big."),

    MsgBadPwd  (401, "message.bad_password", "Invalid password."),

    MsgNotFound(404, "message.not_found",    "No such message."),
    ThrNotFound(404, "thread.not_found",     "No such thread."),

    NotImpl    (501, "not_implemented",      "Not implemented."),
}
