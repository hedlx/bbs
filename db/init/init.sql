DROP TABLE IF EXISTS CASCADE threads;
DROP TABLE IF EXISTS CASCADE messages;

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

CREATE TABLE media (
    message_id    INTEGER,
    fname         VARCHAR NOT NULL, -- url
    size          INTEGER NOT NULL, -- size in bytes

    width         INTEGER NOT NULL, -- pixels
    height        INTEGER NOT NULL, -- pixels

    tn_fname      VARCHAR NOT NULL, -- url
    tn_width      INTEGER NOT NULL, -- pixels
    tn_height     INTEGER NOT NULL  -- pixels
);

CREATE TABLE tags (
    id            INTEGER PRIMARY KEY,
    text          VARCHAR
);

CREATE TABLE message_tags (
    message_id    INTEGER,
    tag_id        INTEGER
);

-- vim: sw=4 ts=4 et:
