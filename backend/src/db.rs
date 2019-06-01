use super::data::{
    DbAttachment, DbFile, DbMessage, DbNewThread, DbThread, File, FullThread,
    Message, NewAttachment, NewMessage, NewThread, ThreadPreview, Threads,
};
use super::error::Error;
use super::image;
use chrono::{NaiveDateTime, Utc};
use diesel::result::DatabaseErrorKind;
use diesel::result::Error as DieselError;
use diesel::sql_types::{BigInt, Integer, Timestamp};
use diesel::Connection;
use diesel::ExpressionMethods;
use diesel::OptionalExtension;
use diesel::QueryDsl;
use diesel::QueryResult;
use diesel::RunQueryDsl;
use diesel::{delete, insert_into, sql_query};
use rocket_contrib::databases::diesel;

#[database("db")]
pub struct Db(diesel::PgConnection);

#[derive(QueryableByName)]
struct Id {
    #[sql_type = "Integer"]
    id: i32,
}

#[derive(QueryableByName)]
struct Count {
    #[sql_type = "BigInt"]
    count: i64,
}

impl Db {
    /* NB: public methods must be wrapped in transactions. */

    pub fn new_thread(&self, thr: NewThread) -> Error {
        let now = Utc::now().naive_utc();

        self.transaction(|| {
            let thread_id = insert_into(super::schema::threads::dsl::threads)
                .values(&DbNewThread {
                    last_reply_no: 0,
                    subject: thr.subject,
                    bump: now,
                })
                .returning(super::schema::threads::dsl::id)
                .get_result(&self.0)?;

            self.insert_message(thr.msg, now, thread_id, 0)
        })
        .unwrap()
    }

    pub fn reply_thread(&self, thread_id: i32, msg: NewMessage) -> Error {
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
                None => return Ok(Error::ThrNotFound),
            };

            self.insert_message(msg, now, thread_id, no)
        })
        .unwrap()
    }

    pub fn get_threads_offset(&self, offset: u32, limit: u32) -> Threads {
        self.transaction(|| {
            let threads = sql_query(r"
                SELECT t.*,
                       (SELECT COUNT(*) FROM messages AS m WHERE m.thread_id = t.id)
                  FROM threads as t
                 ORDER BY (bump, id) ASC
                 LIMIT $2
                 OFFSET $1
            ")
            .bind::<Integer, _>(offset as i32)
            .bind::<Integer, _>(limit as i32)
            .load::<(DbThread, Count)>(&self.0)?
            .into_iter()
            .map(|(thread, total)| self.get_thread_preview(thread, total))
            .collect::<Result<_, _>>()?;
            Ok(Threads{
                count: self.get_thread_count()?,
                threads: threads,
            })
        })
        .unwrap()
    }

    pub fn get_threads_before(&self, ts: u32, limit: u32) -> Threads {
        self.transaction(|| {
            let threads = sql_query(r"
                SELECT t.*,
                       (SELECT COUNT(*) FROM messages AS m WHERE m.thread_id = t.id)
                  FROM threads as t
                 WHERE t.bump > $1
                 ORDER BY (bump, id) ASC
                 LIMIT $2
            ")
            .bind::<Timestamp, _>(NaiveDateTime::from_timestamp(ts as i64, 0))
            .bind::<Integer, _>(limit as i32)
            .load::<(DbThread, Count)>(&self.0)?
            .into_iter()
            .map(|(thread, total)| self.get_thread_preview(thread, total))
            .collect::<Result<_, _>>()?;
            Ok(Threads{
                count: self.get_thread_count()?,
                threads: threads,
            })
        })
        .unwrap()
    }

    pub fn get_thread(&self, thread_id: i32) -> Option<FullThread> {
        self.transaction(|| {
            use super::schema::threads::dsl as d;
            let thread = d::threads
                .filter(d::id.eq(thread_id))
                .get_result::<DbThread>(&self.0)
                .optional()?;

            let thread = match thread {
                Some(thread) => thread,
                None => return Ok(None),
            };

            Ok(Some(FullThread {
                subject: thread.subject,
                messages: self.get_thread_messages(thread_id)?,
            }))
        })
        .unwrap()
    }

    pub fn delete_message(
        &self,
        thread_id: i32,
        no: i32,
        password: String,
    ) -> Error {
        self.transaction(|| {
            use super::schema::messages::dsl as d;
            let message = d::messages
                .filter(d::thread_id.eq(thread_id))
                .filter(d::no.eq(no))
                .get_result::<DbMessage>(&self.0)
                .optional()?;

            let message = match message {
                Some(message) => message,
                None => return Ok(Error::MsgNotFound),
            };

            if message.password != Some(password) {
                return Ok(Error::MsgBadPwd);
            }

            // TODO: simplify to `delete(message)`
            delete(
                d::messages
                    .filter(d::thread_id.eq(thread_id))
                    .filter(d::no.eq(no)),
            )
            .execute(&self.0)?;

            Ok(Error::OK)
        })
        .unwrap()
    }

    pub fn have_file(&self, hash: &String) -> bool {
        self.transaction(|| {
            use super::schema::files::dsl as d;
            let file = d::files
                .filter(d::sha512.eq(hash))
                .get_result::<DbFile>(&self.0)
                .optional()?;

            Ok(file.is_some())
        })
        .unwrap()
    }

    pub fn add_file(&self, info: image::Info, hash: &String) {
        self.transaction(|| {
            insert_into(super::schema::files::dsl::files)
                .values(&DbFile {
                    sha512: hash.clone(),
                    type_: image_type_to_db(info.type_),
                    size: info.size as i32,
                    width: info.width as i32,
                    height: info.height as i32,
                })
                .execute(&self.0)?;
            Ok(())
        })
        .unwrap()
    }

    pub fn delete_thread(&self, _thread_id: i32, _password: String) -> Error {
        Error::NotImpl
    }

    /* Private methods. */

    fn get_thread_preview(
        &self,
        thread: DbThread,
        total: Count,
    ) -> QueryResult<ThreadPreview> {
        let last = self.get_last(thread.id).unwrap();
        let omitted = total.count as i32 - last.len() as i32 - 1;
        Ok(ThreadPreview {
            id: thread.id as u32,
            subject: thread.subject,
            bump: thread.bump.timestamp(),
            op: self.get_op(thread.id)?,
            last: last,
            omitted: omitted,
        })
    }

    fn get_thread_messages(&self, thread_id: i32) -> QueryResult<Vec<Message>> {
        let messages = sql_query(r"
            SELECT m.*,
                   a.*,
                   f.sha512, f.type as type_, f.size, f.width, f.height
              FROM messages AS m
                   LEFT JOIN attachments AS a
                          ON msg_no = no
                         AND msg_thread_id = thread_id
                   LEFT JOIN files AS f
                          ON file_sha512 = sha512
             WHERE thread_id = $1
             ORDER BY no, fno
        ")
        .bind::<Integer, _>(thread_id)
        .get_results::<(DbMessage, Option<DbAttachment>, Option<DbFile>)>(
            &self.0,
        )?;
        Ok(join_messages_files(messages))
    }

    fn get_op(&self, thread_id: i32) -> QueryResult<Message> {
        let messages = sql_query(r"
            SELECT m.*,
                   a.*,
                   f.sha512, f.type as type_, f.size, f.width, f.height
              FROM messages AS m
                   LEFT JOIN attachments AS a
                          ON msg_no = no
                         AND msg_thread_id = thread_id
                   LEFT JOIN files AS f
                          ON file_sha512 = sha512
             WHERE thread_id = $1
               AND no = 0
             ORDER BY fno
        ")
        .bind::<Integer, _>(thread_id)
        .get_results::<(DbMessage, Option<DbAttachment>, Option<DbFile>)>(
            &self.0,
        )?;
        Ok(join_messages_files(messages).remove(0))
    }

    fn get_last(&self, thread_id: i32) -> QueryResult<Vec<Message>> {
        let messages = sql_query(r"
            WITH m AS (SELECT *
                         FROM messages
                        WHERE thread_id = $1
                          AND no != 0
                        ORDER BY no DESC
                        LIMIT 5)
            SELECT m.*,
                   a.*,
                   f.sha512, f.type as type_, f.size, f.width, f.height
              FROM m
                   LEFT JOIN attachments AS a
                          ON msg_no = no
                         AND msg_thread_id = thread_id
                   LEFT JOIN files AS f
                          ON file_sha512 = sha512
             ORDER BY no DESC, fno
        ")
        .bind::<Integer, _>(thread_id)
        .get_results::<(DbMessage, Option<DbAttachment>, Option<DbFile>)>(
            &self.0,
        )?;
        let mut messages = join_messages_files(messages);
        messages.reverse();
        Ok(messages)
    }

    fn get_thread_count(&self) -> QueryResult<i64> {
        super::schema::threads::dsl::threads
            .count()
            .get_result::<i64>(&self.0)
    }

    fn insert_message(
        &self,
        msg: NewMessage,
        ts: NaiveDateTime,
        thread_id: i32,
        no: i32,
    ) -> QueryResult<Error> {
        insert_into(super::schema::messages::dsl::messages)
            .values(&msg_to_db(&msg, ts, thread_id, no))
            .execute(&self.0)?;

        let res = insert_into(super::schema::attachments::dsl::attachments)
            .values(
                msg.media
                    .into_iter()
                    .enumerate()
                    .map(|(fno, a)| attachment_to_db(a, thread_id, no, fno))
                    .collect::<Vec<DbAttachment>>(),
            )
            .execute(&self.0);

        match res {
            Err(DieselError::DatabaseError(
                DatabaseErrorKind::ForeignKeyViolation,
                _,
            )) => Ok(Error::MsgMediaNotFound),
            Err(e) => Err(e),
            Ok(_) => Ok(Error::OK),
        }
    }

    fn transaction<T, F>(&self, f: F) -> Result<T, diesel::result::Error>
    where
        F: FnOnce() -> Result<T, diesel::result::Error>,
    {
        self.0.transaction::<_, diesel::result::Error, _>(f)
    }
}

fn join_messages_files(
    v: Vec<(DbMessage, Option<DbAttachment>, Option<DbFile>)>,
) -> Vec<Message> {
    let mut result: Vec<Message> = Vec::new();
    for (msg, attachment, file) in v {
        let is_same = match &result.last() {
            Some(last) if last.no == msg.no as u32 => true,
            _ => false,
        };
        if !is_same {
            result.push(msg_from_db(msg));
        }
        if let (Some(f), Some(a)) = (file, attachment) {
            result
                .last_mut()
                .unwrap()
                .media
                .push(file_attachment_from_db(f, a));
        }
    }
    result
}

fn msg_from_db(msg: DbMessage) -> Message {
    Message {
        no: msg.no as u32,
        name: msg.name,
        trip: msg.trip,
        text: msg.text,
        ts: msg.ts.timestamp(),
        media: Vec::new(),
    }
}

fn msg_to_db(
    msg: &NewMessage,
    ts: NaiveDateTime,
    thread_id: i32,
    no: i32,
) -> DbMessage {
    DbMessage {
        thread_id: thread_id,
        no: no,
        name: msg.name.clone(),
        trip: msg.secret.clone().map(super::tripcode::generate),
        password: msg.password.clone(),
        sender: String::new(),
        text: msg.text.clone(),
        ts: ts,
    }
}

fn file_attachment_from_db(f: DbFile, a: DbAttachment) -> File {
    File {
        id: f.sha512,
        type_: match f.type_ {
            0 => "image/jpeg".to_string(),
            1 => "image/png".to_string(),
            _ => "application/octet-stream".to_string(),
        },
        orig_name: a.orig_name,
        size: f.size,
        width: f.width,
        height: f.height,
    }
}

fn attachment_to_db(
    a: NewAttachment,
    thread_id: i32,
    msg_no: i32,
    fno: usize,
) -> DbAttachment {
    DbAttachment {
        msg_thread_id: thread_id,
        msg_no: msg_no,
        fno: fno as i16,
        orig_name: a.orig_name,
        file_sha512: a.id,
    }
}

fn image_type_to_db(t: image::Type) -> i16 {
    match t {
        image::Type::Jpg => 0,
        image::Type::Png => 1,
    }
}
