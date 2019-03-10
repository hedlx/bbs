CREATE TABLE threads (
    id            SERIAL PRIMARY KEY,
    last_reply_no INTEGER NOT NULL,
    subject       TEXT,
    bump          TIMESTAMP NOT NULL
);

CREATE TABLE messages (
    thread_id     INTEGER NOT NULL,
    no            INTEGER NOT NULL,

    name          VARCHAR,
    trip          VARCHAR,
    password      VARCHAR,

    sender        TEXT NOT NULL,         -- IP address or telegram id
    text          TEXT NOT NULL,
    ts            TIMESTAMP NOT NULL,

    PRIMARY KEY (thread_id, no),
    FOREIGN KEY (thread_id) REFERENCES threads(id)
);

CREATE TABLE files (
    msg_thread_id INTEGER NOT NULL,
    msg_no        INTEGER NOT NULL,
    fno           SMALLINT NOT NULL, -- used to preserve order

    fname         VARCHAR NOT NULL, -- url
    size          INTEGER NOT NULL, -- size in bytes
    width         INTEGER NOT NULL, -- pixels
    height        INTEGER NOT NULL, -- pixels

    thumb         BYTEA,

    PRIMARY KEY (msg_thread_id, msg_no, fno),
    FOREIGN KEY (msg_thread_id, msg_no) REFERENCES messages ON DELETE CASCADE
);

/*
CREATE TABLE tags (
    id            INTEGER PRIMARY KEY,
    text          VARCHAR
);

CREATE TABLE message_tags (
    message_id    INTEGER,
    tag_id        INTEGER
);
*/

-- vim: sw=4 ts=4 et:
