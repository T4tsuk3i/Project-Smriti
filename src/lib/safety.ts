import type { SafetyCheck, SafetyResource } from './types';

const CRISIS_PATTERN =
  /\b(suicid(?:e|al)|kill myself|kill my self|end my life|end it all|self[-\s]?harm|hurt myself|cut myself|don't want to live|do not want to live|better off dead|no reason to live|can't go on|cannot go on|want to die|overdos(?:e|ing))\b/i;

const RESOURCES: Record<string, SafetyResource[]> = {
  IN: [
    { label: 'Tele-MANAS', contact: '14416', url: 'https://telemanas.mohfw.gov.in/' },
    { label: 'KIRAN', contact: '1800-599-0019' },
    { label: 'AASRA', contact: '+91-9820466726', url: 'https://www.aasra.info/' }
  ],
  US: [
    {
      label: '988 Suicide & Crisis Lifeline',
      contact: 'Call or text 988',
      url: 'https://988lifeline.org/'
    },
    {
      label: 'Crisis Text Line',
      contact: 'Text HOME to 741741',
      url: 'https://www.crisistextline.org/'
    }
  ],
  GB: [
    { label: 'Samaritans', contact: '116 123', url: 'https://www.samaritans.org/' },
    { label: 'Shout', contact: 'Text SHOUT to 85258', url: 'https://giveusashout.org/' }
  ],
  CA: [
    {
      label: '9-8-8 Suicide Crisis Helpline',
      contact: 'Call or text 988',
      url: 'https://988.ca/'
    }
  ],
  AU: [
    { label: 'Lifeline', contact: '13 11 14', url: 'https://www.lifeline.org.au/' },
    {
      label: 'Beyond Blue',
      contact: '1300 22 4636',
      url: 'https://www.beyondblue.org.au/'
    }
  ]
};

export function resourcesFor(country: string): SafetyResource[] {
  return [
    ...(RESOURCES[country.toUpperCase()] ?? []),
    {
      label: 'Find a helpline in your country',
      contact: 'findahelpline.com',
      url: 'https://findahelpline.com/'
    }
  ];
}

export function checkSafety(text: string, country: string): SafetyCheck {
  return {
    flagged: CRISIS_PATTERN.test(text),
    resources: resourcesFor(country)
  };
}
