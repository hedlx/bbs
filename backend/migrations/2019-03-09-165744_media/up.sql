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
