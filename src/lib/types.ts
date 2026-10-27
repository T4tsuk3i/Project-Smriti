export type Tab = 'today' | 'journal' | 'weekly' | 'settings';

export type MoodId = 'good' | 'okay' | 'low' | 'heavy' | 'numb';

export interface Entry {
  id: string;
  content: string;
  createdAt: string;
  mood?: MoodId;
  oneThing?: string;
}

export interface Letter {
  id: string;
  content: string;
  periodStart: string;
  periodEnd: string;
  createdAt: string;
  kind: 'local';
}

export interface Settings {
  userName: string;
  country: string;
  reminderTime: string;
  modelPath: string;
  onboarded: boolean;
}

export interface AppData {
  entries: Entry[];
  letters: Letter[];
  settings: Settings;
}

export interface DayBar {
  date: Date;
  label: string;
  words: number;
  wrote: boolean;
}

export interface WeekStats {
  entries: number;
  words: number;
  days: number;
  bars: DayBar[];
  moods: Record<string, number>;
}

export interface SafetyResource {
  label: string;
  contact: string;
  url?: string;
}

export interface SafetyCheck {
  flagged: boolean;
  resources: SafetyResource[];
}
