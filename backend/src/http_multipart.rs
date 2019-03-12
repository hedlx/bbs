use super::error::Error;
use multipart::server::save::SaveResult;
use multipart::server::save::SavedData;
use multipart::server::save::{SaveDir, TempDir};
use multipart::server::Multipart;
use rocket::http::ContentType;
use rocket::Data;
use std::fs;
use std::fs::File;
use std::io::Write;
use std::path::{Path, PathBuf};
use tempfile;

fn err(s: &'static str) -> Error {
    Error::Upload(s)
}

pub fn extract_file(
    cont_type: &ContentType,
    data: Data,
    temp_dir: &PathBuf,
) -> Result<(TempDir, PathBuf), Error> {
    if !cont_type.is_form_data() {
        return Err(err("Content-Type not multipart/form-data"));
    }

    let (_, boundary) = cont_type
        .params()
        .find(|&(k, _)| k == "boundary")
        .ok_or_else(|| err("`Content-Type: multipart/form-data` boundary param not provided"))?;

    let temp_dir = tempfile::Builder::new()
        .tempdir_in(temp_dir)
        .map_err(|_| err("tempdir"))?;

    let mut entries = match Multipart::with_body(data.open(), boundary)
        .save()
        .ignore_text()
        .with_temp_dir(temp_dir)
    {
        SaveResult::Full(entries) => entries,
        SaveResult::Partial(_partial, _reason) => return Err(err("Partial")),
        SaveResult::Error(_) => return Err(err("Multipart err")),
    };

    // Handle `media`
    let mut media = entries
        .fields
        .remove("media")
        .ok_or_else(|| err("no media"))?;
    if media.len() != 1 {
        return Err(err("You should upload exacly one file"));
    }
    let media = media.remove(0);

    // Handle rest
    if let Some(_) = entries.fields.iter().next() {
        return Err(err("Unexpected key"));
    }

    //
    let temp_dir = match entries.save_dir {
        SaveDir::Temp(x) => x,
        SaveDir::Perm(_) => {
            return Err(err("Directory is permanent, unexpected"))
        }
    };

    //
    let path = temp_dir.path().join("f");
    move_file(media.data, &path).map_err(|_| err("Can't move file"))?;

    Ok((temp_dir, path))
}

fn move_file(data: SavedData, fname: &Path) -> std::io::Result<()> {
    match data {
        SavedData::Text(s) => File::create(fname)?.write_all(s.as_bytes())?,
        SavedData::Bytes(b) => File::create(fname)?.write_all(&b)?,
        SavedData::File(path, _) => fs::rename(path, fname)?,
    };
    Ok(())
}
