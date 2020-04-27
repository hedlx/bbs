CREATE TABLE public.attachments (
    msg_id bigint NOT NULL,
    file_id text NOT NULL
);
CREATE TABLE public.msgs (
    id bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    subject text,
    message text,
    name text DEFAULT 'anonymous'::text NOT NULL,
    tripcode text,
    password text
);
CREATE SEQUENCE public.msgs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER SEQUENCE public.msgs_id_seq OWNED BY public.msgs.id;
CREATE TABLE public.relations (
    target_id bigint NOT NULL,
    source_id bigint NOT NULL
);
ALTER TABLE ONLY public.msgs ALTER COLUMN id SET DEFAULT nextval('public.msgs_id_seq'::regclass);
ALTER TABLE ONLY public.attachments
    ADD CONSTRAINT attachments_pkey PRIMARY KEY (msg_id, file_id);
ALTER TABLE ONLY public.msgs
    ADD CONSTRAINT msgs_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.relations
    ADD CONSTRAINT relations_pkey PRIMARY KEY (target_id, source_id);
ALTER TABLE ONLY public.attachments
    ADD CONSTRAINT attachments_msg_id_fkey FOREIGN KEY (msg_id) REFERENCES public.msgs(id) ON UPDATE RESTRICT ON DELETE CASCADE;
ALTER TABLE ONLY public.relations
    ADD CONSTRAINT relations_child_id_fkey FOREIGN KEY (target_id) REFERENCES public.msgs(id) ON UPDATE RESTRICT ON DELETE CASCADE;
ALTER TABLE ONLY public.relations
    ADD CONSTRAINT relations_parent_id_fkey FOREIGN KEY (source_id) REFERENCES public.msgs(id) ON UPDATE RESTRICT ON DELETE CASCADE;
