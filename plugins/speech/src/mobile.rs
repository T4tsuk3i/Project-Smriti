use serde::de::DeserializeOwned;
use tauri::{
  plugin::{PluginApi, PluginHandle},
  AppHandle, Runtime,
};

#[cfg(target_os = "ios")]
tauri::ios_plugin_binding!(init_plugin_speech);

// initializes the Kotlin or Swift plugin classes
pub fn init<R: Runtime, C: DeserializeOwned>(
  _app: &AppHandle<R>,
  api: PluginApi<R, C>,
) -> crate::Result<Speech<R>> {
  #[cfg(target_os = "android")]
  let handle = api.register_android_plugin("com.t4tsuk3i.smriti.speech", "SpeechPlugin")?;
  #[cfg(target_os = "ios")]
  let handle = api.register_ios_plugin(init_plugin_speech)?;
  Ok(Speech(handle))
}

/// Access to the speech APIs.
pub struct Speech<R: Runtime>(PluginHandle<R>);

impl<R: Runtime> Speech<R> {
  pub fn start(&self) -> crate::Result<()> {
    self.0.run_mobile_plugin("start", ()).map_err(Into::into)
  }

  pub fn stop(&self) -> crate::Result<()> {
    self.0.run_mobile_plugin("stop", ()).map_err(Into::into)
  }

  pub fn cancel(&self) -> crate::Result<()> {
    self.0.run_mobile_plugin("cancel", ()).map_err(Into::into)
  }
}
