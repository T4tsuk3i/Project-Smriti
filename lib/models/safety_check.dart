class SafetyResource {
  const SafetyResource({required this.label, required this.contact, this.url});

  final String label;
  final String contact;
  final String? url;
}

class SafetyCheck {
  const SafetyCheck({required this.flagged, required this.resources});

  final bool flagged;
  final List<SafetyResource> resources;
}
