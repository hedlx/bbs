use super::data::{NewMessage, NewThread};
use super::error::Error;
use super::limits::LIMITS;

pub fn validate_thread(mut thr: NewThread) -> Result<NewThread, Error> {
    thr.msg = validate_message(thr.msg)?;
    thr.subject = trim(thr.subject);
    if let Some(subject) = thr.subject.clone() {
        if subject.len() > LIMITS.msg_subject_len {
            return Err(Error::MsgSubjLong);
        }
    }
    Ok(thr)
}

pub fn validate_message(mut msg: NewMessage) -> Result<NewMessage, Error> {
    msg.text = msg.text.trim().to_owned();
    msg.name = trim(msg.name);
    msg.secret = trim(msg.secret);
    msg.password = trim(msg.password);
    if msg.text.len() == 0 {
        return Err(Error::MsgTextEmpt);
    }
    if msg.text.len() > LIMITS.msg_text_len {
        return Err(Error::MsgTextLong);
    }
    if let Some(name) = msg.name.clone() {
        if name.len() > LIMITS.msg_name_len {
            return Err(Error::MsgNameLong);
        }
    }
    Ok(msg)
}

fn trim(a: Option<String>) -> Option<String> {
    a.map(|s| s.trim().to_owned()).filter(|s| !s.is_empty())
}
