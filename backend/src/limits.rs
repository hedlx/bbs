use serde::Serialize;

macro_rules! mk_limits{
    ( $($id:ident : $type:ty = $value:expr,)* ) => {
        #[derive(Serialize)]
        pub struct Limits {
            $( pub $id : $type, )*
        }

        pub const LIMITS : Limits = Limits {
            $( $id : $value, )*
        };
    }
}

mk_limits! {
    msg_text_len: usize = 4096,
    msg_name_len: usize = 32,
    msg_subject_len: usize = 64,

    media_max_count: usize = 5,
    media_orig_name_len: usize = 128,
    media_content_type: [&'static str; 2] = ["image/png", "image/jpeg"],
    /* XXX: for some reason multipart crate accepts sizes up to
     * 1024*1024*10 + 8047 */
    media_max_file_size: u64 = 10*1024*1024,
    media_max_area: &'static str = "unimplemented",
}
