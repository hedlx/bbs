// TODO: multipart upload https://github.com/SergioBenitez/Rocket/issues/106

use super::error::{error, Error};
use super::events::{validate_message, validate_thread};
use super::limits::{Limits, LIMITS};
use data::{Message, NewMessage, NewThread, Thread};
use db::Db;
use rocket::http::Status;
use rocket_contrib::json::Json;

#[get("/threads?<before>&<after>&<limit>&<tag>")]
fn threads_list(
    db: Db,
    before: Option<u32>, // timestamp
    after: Option<u32>,  // timestamp
    limit: Option<u32>,
    tag: Option<String>,
) -> Json<Vec<Thread>> {
    let limit = limit.unwrap_or(100);
    let resp = match (before, after) {
        (None, None) => db.get_threads_before(0, limit),
        (Some(ts), None) => db.get_threads_before(ts, limit),
        (None, Some(_)) => Vec::new(),
        (Some(_), Some(_)) => Vec::new(),
    };
    Json(resp)
}

#[get("/threads/<id>?<before>&<after>&<limit>")]
fn thread_id(
    db: Db,
    id: i32,
    before: Option<u32>, // message id
    after: Option<u32>,  // message id
    limit: Option<u32>,
) -> Option<Json<Vec<Message>>> {
    let limit = limit.unwrap_or(100);
    match (before, after) {
        (None, None) => db.get_thread_messages(id).map(Json),
        (Some(_), None) => None,    // before
        (None, Some(_)) => None,    // after
        (Some(_), Some(_)) => None, // range / 400
    }
}

#[post("/threads", format = "json", data = "<thr>")]
fn thread_new(db: Db, thr: Json<NewThread>) -> Result<&'static str, Error> {
    let thr = validate_thread(thr.0).map_err(|(e, c)| error(Status::BadRequest, e, c))?;
    db.new_thread(thr);
    Ok("{}")
}

#[post("/threads/<id>", format = "json", data = "<msg>")]
fn thread_reply(db: Db, id: i32, msg: Json<NewMessage>) -> Result<&'static str, Error> {
    let msg = validate_message(msg.0).map_err(|(e, c)| error(Status::BadRequest, e, c))?;
    if db.reply_thread(id, msg) {
        Ok("{}")
    } else {
        Err(error(
            Status::NotFound,
            "No such thread.",
            "thread.not_found",
        ))
    }
}

#[delete("/threads/<id>?<password>")]
fn api_delete_thread(db: Db, id: i32, password: String) -> Result<&'static str, Error> {
    match db.delete_thread(id, password) {
        Some(err) => Err(err),
        None => Ok("{}"),
    }
}

#[delete("/threads/<id>/replies/<no>?<password>")]
fn api_delete_thread_reply(
    db: Db,
    id: i32,
    no: i32,
    password: String,
) -> Result<&'static str, Error> {
    match db.delete_message(id, no, password) {
        Some(err) => Err(err),
        None => Ok("{}"),
    }
}

#[get("/limits")]
fn limits() -> Json<Limits> {
    Json(LIMITS)
}

use juniper::{Context as JuniperContext, RootNode, EmptyMutation};

impl JuniperContext for Db {}

pub struct QueryRoot;

graphql_object!(QueryRoot: Db |&self| {
    field some() -> i32 {
        1234
    }
    field items() -> Vec<i32>
    {
        vec![1,2,3,4]
    }
});

type Schema = RootNode<'static, QueryRoot, EmptyMutation<Db>>;

#[post("/graphql", data = "<request>")]
fn api_get_graphql(
    db: Db,
    //schema: rocket::State<Schema>,
    request: juniper_rocket::GraphQLRequest,
) -> juniper_rocket::GraphQLResponse {
    let schema = Schema::new(QueryRoot, EmptyMutation::new());
    request.execute(&schema, &db)
}

pub fn start() {
    rocket::ignite()
        .attach(Db::fairing())
        //.manage(Schema::new(QueryRoot, EmptyMutation::new()))
        .mount(
            "/",
            routes![
                api_delete_thread,
                api_delete_thread_reply,
                api_get_graphql,
                limits,
                thread_id,
                thread_new,
                thread_reply,
                threads_list,
            ],
        )
        .launch();
}
