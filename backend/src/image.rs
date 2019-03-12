use std::fs::File;
use std::path::PathBuf;
use subprocess::Exec;

#[derive(Debug)]
pub struct Info {
    pub type_: Type,
    pub size: u64,
    pub width: u32,
    pub height: u32,
}

#[derive(Debug)]
pub enum Type {
    Jpg,
    Png,
}

pub fn get_info(fname: &PathBuf) -> Option<Info> {
    if let Some(dims) = try_jpeg(fname) {
        return rest(fname, dims, Type::Jpg);
    }
    if let Some(dims) = try_png(fname) {
        return rest(fname, dims, Type::Png);
    }
    None
}

fn try_jpeg(fname: &PathBuf) -> Option<(u32, u32)> {
    let mut a = jpeg_decoder::Decoder::new(File::open(fname).ok()?);
    a.read_info().ok()?;
    let info = a.info()?;
    Some((info.width as u32, info.height as u32))
}

fn try_png(fname: &PathBuf) -> Option<(u32, u32)> {
    let info = png::Decoder::new(File::open(fname).ok()?)
        .read_info()
        .ok()?
        .0;
    Some((info.width, info.height))
}

fn rest(fname: &PathBuf, dims: (u32, u32), type_: Type) -> Option<Info> {
    Some(Info {
        type_: type_,
        size: File::open(fname).ok()?.metadata().ok()?.len(),
        width: dims.0,
        height: dims.1,
    })
}

pub fn make_thumb(fname: &PathBuf) -> Option<PathBuf> {
    let thumb_fname = fname.with_extension("thumb");
    let im = Exec::cmd("./im/im.sh")
        .arg(fname)
        .arg(&thumb_fname)
        .capture()
        .ok()?;
    if !im.success() {
        return None;
    }
    Some(thumb_fname)
}
