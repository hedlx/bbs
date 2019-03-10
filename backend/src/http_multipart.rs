use super::error::Error;
use multipart::server::save::SaveResult::*;
use multipart::server::save::SavedData;
use multipart::server::save::{SaveDir, TempDir};
use multipart::server::Multipart;
use multipart::server::SavedField;
use rocket::http::hyper::mime::{Mime, SubLevel, TopLevel};
use rocket::http::ContentType;
use rocket::Data;
use serde_json;
use std::fs;
use std::fs::File;
use std::io::Write;
use std::path::{Path, PathBuf};
use subprocess::{Exec, Redirection};

fn err(s: &'static str) -> Error {
    Error::Upload(s)
}

pub struct MediaFiles0 {
    temp_dir: TempDir,
    fields: Vec<SavedField>,
}

#[derive(Debug)]
pub struct MediaFiles1 {
    pub temp_dir: TempDir,
    pub files: Vec<MediaFile1>,
}

#[derive(Debug)]
pub struct MediaFile1 {
    pub path: PathBuf,
    pub size: i32,
    pub width: i32,
    pub height: i32,
    pub thumb: Option<Vec<u8>>,
}

impl MediaFiles0 {
    pub fn process(self) -> Result<MediaFiles1, Error> {
        let files = {
            let path = self.temp_dir.path();
            self.fields
                .into_iter()
                .enumerate()
                .map(|(n, item)| process(&path, n, item))
                .collect::<Result<Vec<MediaFile1>, Error>>()?
        };
        Ok(MediaFiles1 {
            temp_dir: self.temp_dir,
            files: files,
        })
    }
}

pub fn process_upload<Payload: serde::de::DeserializeOwned>(
    cont_type: &ContentType,
    data: Data,
) -> Result<(Payload, MediaFiles0), Error> {
    if !cont_type.is_form_data() {
        return Err(err("Content-Type not multipart/form-data"));
    }

    let (_, boundary) = cont_type
        .params()
        .find(|&(k, _)| k == "boundary")
        .ok_or_else(|| err("`Content-Type: multipart/form-data` boundary param not provided"))?;

    let mut entries = match Multipart::with_body(data.open(), boundary)
        .save()
        .ignore_text()
        .temp()
    {
        Full(entries) => entries,
        Partial(_partial, _reason) => return Err(err("partial")),
        Error(_) => return Err(err("multipart err")),
    };

    // Handle `media[]`
    let media = entries
        .fields
        .remove("media[]")
        .ok_or_else(|| err("no media[]"))?;
    if media.len() > 5 {
        return Err(err("media[] len"));
    }

    // Handle `message`
    let message = entries
        .fields
        .remove("message")
        .ok_or_else(|| err("no message"))?;
    let message = if message.len() == 1 {
        &message[0]
    } else {
        return Err(err("message.len"));
    };
    match message.headers.content_type {
        Some(Mime(TopLevel::Application, SubLevel::Json, _)) => {}
        _ => return Err(err("message isn't application/json")),
    }
    let message = match &message.data {
        SavedData::Text(s) => s.as_bytes(),
        SavedData::Bytes(b) => b.as_slice(),
        SavedData::File(_, _) => return Err(err("mesage is too big")),
    };
    let message = serde_json::from_slice::<Payload>(message).map_err(|_| err("woof"))?;

    // Handle rest
    if let Some(_) = entries.fields.iter().next() {
        return Err(err("unexpected key"));
    }

    let temp_dir = match entries.save_dir {
        SaveDir::Temp(x) => x,
        SaveDir::Perm(_) => return Err(err("Directory is permanent, unexpected")),
    };

    Ok((
        message,
        MediaFiles0 {
            temp_dir,
            fields: media,
        },
    ))
}

fn process(temp_dir: &Path, fno: usize, item: SavedField) -> Result<MediaFile1, Error> {
    let (format, extension) = match item.headers.content_type {
        Some(Mime(TopLevel::Image, SubLevel::Png, _)) => ("PNG", "png"),
        Some(Mime(TopLevel::Image, SubLevel::Jpeg, _)) => ("JPG", "jpeg"),
        _ => return Err(err("Unsupported mime")),
    };
    let fname = temp_dir.join(format!("{}.{}", fno, extension));
    move_file(item.data, &fname).map_err(|_| err("move file"))?;
    let dimensions = dimensions(&fname, format).map_err(|_| err("dimensions"))?;
    let thumb = thumb(&fname, format).map_err(|_| err("thumb"))?;
    Ok(MediaFile1 {
        path: fname,
        size: 0, // TODO
        width: dimensions.0,
        height: dimensions.1,
        thumb: thumb,
    })
}

fn move_file(data: SavedData, fname: &Path) -> std::io::Result<()> {
    match data {
        SavedData::Text(s) => File::create(fname)?.write_all(s.as_bytes())?,
        SavedData::Bytes(b) => File::create(fname)?.write_all(&b)?,
        SavedData::File(path, _) => fs::rename(path, fname)?,
    };
    Ok(())
}

fn thumb(fname: &PathBuf, format: &str) -> Result<Option<Vec<u8>>, ()> {
    let result = Exec::cmd("./im/im.sh")
        .arg("thumb")
        .arg(format)
        .stdin(File::open(&fname).map_err(|_| ())?)
        .stdout(Redirection::Pipe)
        .capture()
        .map_err(|_| ())?;
    if !result.success() {
        return Ok(None);
    }
    Ok(Some(result.stdout))
}

fn dimensions(fname: &PathBuf, format: &str) -> Result<(i32, i32), ()> {
    let result = Exec::cmd("./im/im.sh")
        .arg("dimensions")
        .arg(format)
        .stdin(File::open(&fname).map_err(|_| ())?)
        .stdout(Redirection::Pipe)
        .capture()
        .map_err(|_| ())?;
    if !result.success() {
        return Err(());
    }
    let result = result
        .stdout_str()
        .split_whitespace()
        .map(|x| x.parse::<i32>().map_err(|_| ()))
        .collect::<Result<Vec<i32>, ()>>()?;
    Ok((*result.get(0).ok_or(())?, *result.get(1).ok_or(())?))
}
