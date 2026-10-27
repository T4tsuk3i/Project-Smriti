/// The boundary between the journal UI and an on-device model.
///
/// This is intentionally blank for now. Smriti does not bundle a model, download
/// one, or call a cloud endpoint. When on-device inference lands, this is the
/// single place the rest of the app will ask for it.
class ModelService {
  ModelService._();

  static const bool isConfigured = false;
  static const String label = 'No model on this phone';
  static const String shortStatus = 'Not set up';

  static const String explanation =
      'You can write without a model. The reflective parts stay off until a '
      'model is on your phone. Nothing is downloaded or sent anywhere.';

  static const String roadmapNote =
      'Later: choose a local GGUF file and run it on the device. No server.';
}
