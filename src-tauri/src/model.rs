use serde::{Deserialize, Serialize};
use std::fs;
use std::io::Read;
use std::path::{Path, PathBuf};
use std::time::Duration;
use tauri::{AppHandle, Manager};

#[derive(Serialize)]
pub struct ModelStatus {
    pub configured: bool,
    /// "edge", "api", or "none"
    pub provider: String,
    pub path: Option<String>,
    pub name: Option<String>,
    pub size_bytes: Option<u64>,
    pub base_url: Option<String>,
    pub model: Option<String>,
    pub has_api_key: bool,
    pub message: String,
}

#[derive(Default, Deserialize, Serialize)]
struct ModelConfig {
    provider: Option<String>,
    path: Option<String>,
    base_url: Option<String>,
    model: Option<String>,
    api_key: Option<String>,
}

fn config_path(app: &AppHandle) -> Result<PathBuf, String> {
    let dir = app
        .path()
        .app_data_dir()
        .map_err(|error| format!("Could not find app data directory: {error}"))?;
    fs::create_dir_all(&dir)
        .map_err(|error| format!("Could not create app data directory: {error}"))?;
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

fn none_status(message: &str) -> ModelStatus {
    ModelStatus {
        configured: false,
        provider: "none".to_string(),
        path: None,
        name: None,
        size_bytes: None,
        base_url: None,
        model: None,
        has_api_key: false,
        message: message.to_string(),
    }
}

fn edge_status(path: Option<String>) -> ModelStatus {
    let Some(value) = path else {
        return none_status("No model selected.");
    };

    let file = Path::new(&value);
    let name = file
        .file_name()
        .and_then(|name| name.to_str())
        .map(|name| name.to_string());

    match fs::metadata(file) {
        Ok(metadata) if metadata.is_file() && is_gguf(file) => ModelStatus {
            configured: true,
            provider: "edge".to_string(),
            path: Some(value),
            name,
            size_bytes: Some(metadata.len()),
            base_url: None,
            model: None,
            has_api_key: false,
            message: "GGUF model ready on this phone.".to_string(),
        },
        Ok(metadata) if metadata.is_file() => ModelStatus {
            configured: false,
            provider: "edge".to_string(),
            path: Some(value),
            name,
            size_bytes: Some(metadata.len()),
            base_url: None,
            model: None,
            has_api_key: false,
            message: "That file is not a GGUF model.".to_string(),
        },
        _ => {
            let mut status = none_status("The selected model file is missing. Choose it again.");
            status.provider = "edge".to_string();
            status
        }
    }
}

fn api_status(config: &ModelConfig) -> ModelStatus {
    let base_url = config.base_url.clone().unwrap_or_default();
    let model = config.model.clone().unwrap_or_default();
    let configured = !base_url.is_empty() && !model.is_empty();

    ModelStatus {
        configured,
        provider: "api".to_string(),
        path: None,
        name: None,
        size_bytes: None,
        base_url: Some(base_url.clone()),
        model: Some(model.clone()),
        has_api_key: config.api_key.as_deref().unwrap_or_default().len() > 0,
        message: if configured {
            "API model configured.".to_string()
        } else {
            "Add an endpoint and model name.".to_string()
        },
    }
}

fn status_for(config: &ModelConfig) -> ModelStatus {
    match config.provider.as_deref() {
        Some("api") => api_status(config),
        Some("edge") => edge_status(config.path.clone()),
        _ => none_status("No model selected."),
    }
}

fn endpoint(base_url: &str) -> String {
    let base = base_url.trim().trim_end_matches('/');
    if base.ends_with("/chat/completions") {
        return base.to_string();
    }
    if base.ends_with("/v1") {
        return format!("{base}/chat/completions");
    }
    format!("{base}/v1/chat/completions")
}

#[tauri::command]
pub fn model_status(app: AppHandle) -> ModelStatus {
    status_for(&read_config(&app))
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

    let config = ModelConfig {
        provider: Some("edge".to_string()),
        path: Some(trimmed.to_string()),
        ..ModelConfig::default()
    };
    write_config(&app, &config)?;
    Ok(status_for(&config))
}

#[tauri::command]
pub fn set_api_model(
    app: AppHandle,
    base_url: String,
    model: String,
    api_key: Option<String>,
) -> Result<ModelStatus, String> {
    let base = base_url.trim();
    let model = model.trim();

    if base.is_empty() {
        return Err("Add the PC or API endpoint.".to_string());
    }
    if model.is_empty() {
        return Err("Add the model name.".to_string());
    }

    let parsed = reqwest::Url::parse(base).map_err(|_| "That endpoint is not a valid URL.".to_string())?;
    if !["http", "https"].contains(&parsed.scheme()) {
        return Err("Use an http:// or https:// endpoint.".to_string());
    }

    let existing = read_config(&app);
    let config = ModelConfig {
        provider: Some("api".to_string()),
        base_url: Some(base.to_string()),
        model: Some(model.to_string()),
        api_key: api_key
            .filter(|value| !value.trim().is_empty())
            .or(existing.api_key),
        ..ModelConfig::default()
    };
    write_config(&app, &config)?;
    Ok(status_for(&config))
}

#[tauri::command]
pub async fn test_api_model(
    app: AppHandle,
    base_url: String,
    model: String,
    api_key: Option<String>,
) -> Result<String, String> {
    let api_key = api_key
        .filter(|value| !value.trim().is_empty())
        .or(read_config(&app).api_key);
    let client = reqwest::Client::builder()
        .timeout(Duration::from_secs(15))
        .build()
        .map_err(|error| format!("Could not create HTTP client: {error}"))?;

    let mut request = client.post(endpoint(&base_url)).json(&serde_json::json!({
        "model": model,
        "messages": [{ "role": "user", "content": "Reply with exactly: OK" }],
        "temperature": 0,
        "max_tokens": 8
    }));

    if let Some(key) = api_key.filter(|value| !value.trim().is_empty()) {
        request = request.header("Authorization", format!("Bearer {key}"));
    }

    let response = request
        .send()
        .await
        .map_err(|error| format!("Could not reach the endpoint: {error}"))?;

    if !response.status().is_success() {
        return Err(format!("Endpoint returned {}.", response.status()));
    }

    Ok("Connected. The model replied.".to_string())
}

#[tauri::command]
pub fn clear_model(app: AppHandle) -> Result<ModelStatus, String> {
    write_config(&app, &ModelConfig::default())?;
    Ok(none_status("No model selected."))
}
