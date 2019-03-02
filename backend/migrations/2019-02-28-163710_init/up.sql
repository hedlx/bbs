CREATE TABLE threads (
    id            SERIAL PRIMARY KEY,
    last_reply_no INTEGER NOT NULL,
    bump          TIMESTAMP NOT NULL
);

CREATE TABLE messages (
    thread_id     INTEGER NOT NULL,
    no            INTEGER NOT NULL,

    name          VARCHAR,
    trip          VARCHAR,

    sender        TEXT NOT NULL,         -- IP address or telegram id
    text          TEXT NOT NULL,
    ts            TIMESTAMP NOT NULL,

    PRIMARY KEY (thread_id, no),
    FOREIGN KEY (thread_id) REFERENCES threads(id)
);

-- vim: sw=4 ts=4 et:
