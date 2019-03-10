table! {
    files (msg_thread_id, msg_no, fno) {
        msg_thread_id -> Int4,
        msg_no -> Int4,
        fno -> Int2,
        fname -> Varchar,
        size -> Int4,
        width -> Int4,
        height -> Int4,
        thumb -> Nullable<Bytea>,
    }
}

table! {
    messages (thread_id, no) {
        thread_id -> Int4,
        no -> Int4,
        name -> Nullable<Varchar>,
        trip -> Nullable<Varchar>,
        sender -> Text,
        text -> Text,
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

joinable!(messages -> threads (thread_id));

allow_tables_to_appear_in_same_query!(
    files,
    messages,
    threads,
);
