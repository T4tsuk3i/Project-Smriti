import '../models/safety_check.dart';

class SafetyService {
  SafetyService._();

  static final RegExp _crisisPattern = RegExp(
    r"\b(suicid(?:e|al)|kill myself|kill my self|end my life|end it all|self[-\s]?harm|hurt myself|cut myself|don't want to live|do not want to live|better off dead|no reason to live|can't go on|cannot go on|want to die|overdos(?:e|ing))\b",
    caseSensitive: false,
  );

  static const Map<String, List<SafetyResource>> _resources = {
    'IN': [
      SafetyResource(
        label: 'Tele-MANAS',
        contact: '14416',
        url: 'https://telemanas.mohfw.gov.in/',
      ),
      SafetyResource(label: 'KIRAN', contact: '1800-599-0019'),
      SafetyResource(
        label: 'AASRA',
        contact: '+91-9820466726',
        url: 'https://www.aasra.info/',
      ),
    ],
    'US': [
      SafetyResource(
        label: '988 Suicide & Crisis Lifeline',
        contact: 'Call or text 988',
        url: 'https://988lifeline.org/',
      ),
      SafetyResource(
        label: 'Crisis Text Line',
        contact: 'Text HOME to 741741',
        url: 'https://www.crisistextline.org/',
      ),
    ],
    'GB': [
      SafetyResource(
        label: 'Samaritans',
        contact: '116 123',
        url: 'https://www.samaritans.org/',
      ),
      SafetyResource(
        label: 'Shout',
        contact: 'Text SHOUT to 85258',
        url: 'https://giveusashout.org/',
      ),
    ],
    'CA': [
      SafetyResource(
        label: '9-8-8 Suicide Crisis Helpline',
        contact: 'Call or text 988',
        url: 'https://988.ca/',
      ),
    ],
    'AU': [
      SafetyResource(
        label: 'Lifeline',
        contact: '13 11 14',
        url: 'https://www.lifeline.org.au/',
      ),
      SafetyResource(
        label: 'Beyond Blue',
        contact: '1300 22 4636',
        url: 'https://www.beyondblue.org.au/',
      ),
    ],
  };

  static SafetyCheck check(String text, {String country = 'IN'}) {
    return SafetyCheck(
      flagged: _crisisPattern.hasMatch(text),
      resources: resourcesFor(country),
    );
  }

  static List<SafetyResource> resourcesFor(String country) {
    return [
      ...(_resources[country.toUpperCase()] ?? const <SafetyResource>[]),
      const SafetyResource(
        label: 'Find a helpline in your country',
        contact: 'findahelpline.com',
        url: 'https://findahelpline.com/',
      ),
    ];
  }
}
