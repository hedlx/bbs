use super::data::NewMessage;

pub fn validate_message(mut msg: NewMessage)
    -> Result<NewMessage, (&'static str, &'static str)>
{
    msg.text = msg.text.trim().to_owned();
    msg.name = trim(msg.name);
    msg.secret = trim(msg.secret);
    if msg.text.len() == 0 {
        return Err(("Text should not be empty.", "message.text_empty"))
    }
    if msg.text.len() > 4096 {
        return Err(("Text should be no more than 4096 characters long.", "message.text_long"))
    }
    if let Some(name) = msg.name.clone() {
        if name.len() > 32 {
            return Err(("Name should be no more than 32 characters long.", "message.name_long"))
        }
    }
    Ok(msg)
}

fn trim(a: Option<String>) -> Option<String> {
    a.map(|s|s.trim().to_owned()).filter(|s|!s.is_empty())
}
