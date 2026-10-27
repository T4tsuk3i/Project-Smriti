use serde::{Deserialize, Serialize};
use std::fs;
use std::io::Read;
use std::path::{Path, PathBuf};
use tauri::{AppHandle, Manager};

#[derive(Serialize)]
pub struct ModelStatus {
    pub configured: bool,
    pub path: Option<String>,
    pub name: Option<String>,
    pub size_bytes: Option<u64>,
    pub message: String,
}

#[derive(Default, Deserialize, Serialize)]
struct ModelConfig {
    path: Option<String>,
}

fn config_path(app: &AppHandle) -> Result<PathBuf, String> {
    let dir = app
        .path()
        .app_data_dir()
        .map_err(|error| format!("Could not find app data directory: {error}"))?;
    fs::create_dir_all(&dir).map_err(|error| format!("Could not create app data directory: {error}"))?;
    Ok(dir.join("model.json"))
}

fn read_config(app: &AppHandle) -> ModelConfig {
    let Ok(path) = config_path(app) else {
        return ModelConfig::default();
    };
    let Ok(raw) = fs::read_to_string(path) else {
        return ModelConfig::default();
    };
    serde_json::from_str(&raw).unwrap_or_default()
}

fn write_config(app: &AppHandle, config: &ModelConfig) -> Result<(), String> {
    let path = config_path(app)?;
    let raw = serde_json::to_string_pretty(config)
        .map_err(|error| format!("Could not serialize model config: {error}"))?;
    fs::write(path, raw).map_err(|error| format!("Could not save model config: {error}"))
}

fn is_gguf(file: &Path) -> bool {
    let Ok(mut handle) = fs::File::open(file) else {
        return false;
    };
    let mut magic = [0_u8; 4];
    handle.read_exact(&mut magic).is_ok() && &magic == b"GGUF"
}

fn status_for(path: Option<String>) -> ModelStatus {
    let Some(value) = path else {
        return ModelStatus {
            configured: false,
            path: None,
            name: None,
            size_bytes: None,
            message: "No model selected.".to_string(),
        };
    };

    let file = Path::new(&value);
    let name = file
        .file_name()
        .and_then(|name| name.to_str())
        .map(|name| name.to_string());

    match fs::metadata(file) {
        Ok(metadata) if metadata.is_file() && is_gguf(file) => ModelStatus {
            configured: true,
            path: Some(value),
            name,
            size_bytes: Some(metadata.len()),
            message: "Model file ready.".to_string(),
        },
        Ok(metadata) if metadata.is_file() => ModelStatus {
            configured: false,
            path: Some(value),
            name,
            size_bytes: Some(metadata.len()),
            message: "That file is not a GGUF model.".to_string(),
        },
        _ => ModelStatus {
            configured: false,
            path: Some(value),
            name,
            size_bytes: None,
            message: "The selected model file is missing. Choose it again.".to_string(),
        },
    }
}

#[tauri::command]
pub fn model_status(app: AppHandle) -> ModelStatus {
    let config = read_config(&app);
    status_for(config.path)
}

#[tauri::command]
pub fn set_model_path(app: AppHandle, path: String) -> Result<ModelStatus, String> {
    let trimmed = path.trim();
    if trimmed.is_empty() {
        return Err("No model file selected.".to_string());
    }

    let file = Path::new(trimmed);
    if !file.is_file() {
        return Err("That file cannot be read. Pick a GGUF file stored on this device.".to_string());
    }

    let extension = file
        .extension()
        .and_then(|value| value.to_str())
        .unwrap_or_default()
        .to_ascii_lowercase();
    if extension != "gguf" {
        return Err("Pick a .gguf model file.".to_string());
    }
    if !is_gguf(file) {
        return Err("That file is not a valid GGUF model.".to_string());
    }

    write_config(
        &app,
        &ModelConfig {
            path: Some(trimmed.to_string()),
        },
    )?;

    Ok(status_for(Some(trimmed.to_string())))
}

#[tauri::command]
pub fn clear_model(app: AppHandle) -> Result<ModelStatus, String> {
    write_config(&app, &ModelConfig { path: None })?;
    Ok(status_for(None))
}
