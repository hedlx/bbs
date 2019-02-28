table! {
    messages (thread_id, no) {
        thread_id -> Int4,
        no -> Int4,
        name -> Nullable<Varchar>,
        trip -> Nullable<Varchar>,
        sender -> Text,
        text -> Text,
        ts -> Timestamp,
    }
}

table! {
    threads (id) {
        id -> Int4,
        last_reply_no -> Int4,
        bump -> Timestamp,
    }
}

joinable!(messages -> threads (thread_id));

allow_tables_to_appear_in_same_query!(
    messages,
    threads,
);
