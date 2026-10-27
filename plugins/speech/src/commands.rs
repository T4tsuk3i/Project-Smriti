use tauri::{command, AppHandle, Runtime};

use crate::Result;
use crate::SpeechExt;

#[command]
pub(crate) async fn start<R: Runtime>(app: AppHandle<R>) -> Result<()> {
  app.speech().start()
}

#[command]
pub(crate) async fn stop<R: Runtime>(app: AppHandle<R>) -> Result<()> {
  app.speech().stop()
}

#[command]
pub(crate) async fn cancel<R: Runtime>(app: AppHandle<R>) -> Result<()> {
  app.speech().cancel()
}
