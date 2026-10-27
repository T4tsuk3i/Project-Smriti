use serde::de::DeserializeOwned;
use tauri::{plugin::PluginApi, AppHandle, Runtime};

use crate::{Error, Result};

pub fn init<R: Runtime, C: DeserializeOwned>(
  app: &AppHandle<R>,
  _api: PluginApi<R, C>,
) -> Result<Speech<R>> {
  Ok(Speech(app.clone()))
}

pub struct Speech<R: Runtime>(AppHandle<R>);

impl<R: Runtime> Speech<R> {
  pub fn start(&self) -> Result<()> {
    Err(Error::Unsupported)
  }

  pub fn stop(&self) -> Result<()> {
    Ok(())
  }

  pub fn cancel(&self) -> Result<()> {
    Ok(())
  }
}
