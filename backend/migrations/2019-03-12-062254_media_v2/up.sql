drop table files;
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
