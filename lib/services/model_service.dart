/// The boundary between the journal UI and an on-device model.
///
/// This is intentionally blank for now. Smriti does not bundle a model, download
/// one, or call a cloud endpoint. When on-device inference lands, this is the
/// single place the rest of the app will ask for it.
class ModelService {
  ModelService._();

  static const bool isConfigured = false;
  static const String label = 'No on-device model';
  static const String shortStatus = 'Not configured';

  static const String explanation =
      'Smriti does not bundle or download a model, and it does not call a cloud '
      'endpoint. Journaling works without one. On-device reflection will arrive '
      'when the local model runtime is wired.';

  static const String roadmapNote =
      'Planned: pick a local GGUF on your phone, run it with llama.cpp, keep '
      'inference on the device.';
}
