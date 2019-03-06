use serde::Serialize;
use serde_json;

macro_rules! mk_limits{
    ( $($id:ident : $type:ident = $value:expr,)* ) => {
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
}
