CREATE TABLE messages (
	id        INTEGER PRIMARY KEY,
	thread_id INTEGER NOT NULL,     -- 0 for original posts, or `id` of OP

	name      VARCHAR,
	trip      VARCHAR,

	sender   TEXT NOT NULL,         -- IP address or telegram id
	message  TEXT,
	ts       TIMESTAMP
);

CREATE TABLE media (
	message_id INTEGER,
	fname      VARCHAR NOT NULL, -- url
	size       INTEGER NOT NULL, -- size in bytes

	width      INTEGER NOT NULL, -- pixels
	height     INTEGER NOT NULL, -- pixels

	tn_fname   VARCHAR NOT NULL, -- url
	tn_width   INTEGER NOT NULL, -- pixels
	tn_height  INTEGER NOT NULL, -- pixels
);

CREATE TABLE tags (
	id   INTEGER PRIMARY KEY,
	text VARCHAR
);

CREATE TABLE message_tags (
	message_id INTEGER,
	tag_id     INTEGER
);
