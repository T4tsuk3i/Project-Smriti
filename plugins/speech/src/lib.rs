use tauri::{
  plugin::{Builder, TauriPlugin},
  Manager, Runtime,
};

pub use models::*;

#[cfg(desktop)]
mod desktop;
#[cfg(mobile)]
mod mobile;

mod commands;
mod error;
mod models;

pub use error::{Error, Result};

#[cfg(desktop)]
use desktop::Speech;
#[cfg(mobile)]
use mobile::Speech;

pub trait SpeechExt<R: Runtime> {
  fn speech(&self) -> &Speech<R>;
}

impl<R: Runtime, T: Manager<R>> crate::SpeechExt<R> for T {
  fn speech(&self) -> &Speech<R> {
    self.state::<Speech<R>>().inner()
  }
}

pub fn init<R: Runtime>() -> TauriPlugin<R> {
  Builder::new("speech")
    .invoke_handler(tauri::generate_handler![
      commands::start,
      commands::stop,
      commands::cancel
    ])
    .setup(|app, api| {
      #[cfg(mobile)]
      let speech = mobile::init(app, api)?;
      #[cfg(desktop)]
      let speech = desktop::init(app, api)?;
      app.manage(speech);
      Ok(())
    })
    .build()
}
