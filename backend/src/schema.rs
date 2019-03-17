table! {
    attachments (msg_thread_id, msg_no, fno) {
        msg_thread_id -> Int4,
        msg_no -> Int4,
        fno -> Int2,
        orig_name -> Varchar,
        file_sha512 -> Varchar,
    }
}

table! {
    files (sha512) {
        sha512 -> Varchar,
        #[sql_name = "type"]
        type_ -> Int2,
        size -> Int4,
        width -> Int4,
        height -> Int4,
    }
}

table! {
    messages (thread_id, no) {
        thread_id -> Int4,
        no -> Int4,
        name -> Nullable<Varchar>,
        trip -> Nullable<Varchar>,
        sender -> Text,
        text -> Nullable<Text>,
        ts -> Timestamp,
        password -> Nullable<Varchar>,
    }
}

table! {
    threads (id) {
        id -> Int4,
        last_reply_no -> Int4,
        bump -> Timestamp,
        subject -> Nullable<Text>,
    }
}

joinable!(attachments -> files (file_sha512));
joinable!(messages -> threads (thread_id));

allow_tables_to_appear_in_same_query!(
    attachments,
    files,
    messages,
    threads,
);
