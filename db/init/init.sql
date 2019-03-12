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
    sha512 VARCHAR PRIMARY KEY,
    type   SMALLINT NOT NULL, -- 0:jpg 1:png
    size   INTEGER NOT NULL,

    width  INTEGER NOT NULL,
    height INTEGER NOT NULL
);

CREATE TABLE attachments (
    msg_thread_id INTEGER NOT NULL,
    msg_no        INTEGER NOT NULL,
    fno           SMALLINT NOT NULL, -- used to preserve order

    orig_name     VARCHAR NOT NULL, -- original filename
    file_sha512   VARCHAR NOT NULL,

    PRIMARY KEY (msg_thread_id, msg_no, fno),
    FOREIGN KEY (msg_thread_id, msg_no) REFERENCES messages ON DELETE CASCADE,
    FOREIGN KEY (file_sha512) REFERENCES files ON DELETE SET NULL
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
