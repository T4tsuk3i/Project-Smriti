#[tauri::command]
fn core_version() -> String {
    smriti_core::version().to_string()
}

#[tauri::command]
fn decay_score(importance: f64, days: f64, half_life_days: f64) -> f64 {
    smriti_core::decay(importance, days, half_life_days)
}

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    tauri::Builder::default()
        .plugin(tauri_plugin_opener::init())
        .invoke_handler(tauri::generate_handler![core_version, decay_score])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
