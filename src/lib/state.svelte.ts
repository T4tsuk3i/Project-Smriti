import type {
  AppData,
  Entry,
  Letter,
  MoodId,
  Settings
} from './types';

const STORAGE_KEY = 'smriti.tauri.v1';

const DEFAULT_SETTINGS: Settings = {
  userName: '',
  country: 'IN',
  reminderTime: '20:00',
  modelPath: '',
  onboarded: false
};

function emptyData(): AppData {
  return { entries: [], letters: [], settings: { ...DEFAULT_SETTINGS } };
}

function load(): AppData {
  if (typeof localStorage === 'undefined') return emptyData();
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (!raw) return emptyData();
    const parsed = JSON.parse(raw) as Partial<AppData>;
    return {
      entries: Array.isArray(parsed.entries) ? parsed.entries : [],
      letters: Array.isArray(parsed.letters) ? parsed.letters : [],
      settings: { ...DEFAULT_SETTINGS, ...(parsed.settings ?? {}) }
    };
  } catch {
    return emptyData();
  }
}

export const app = $state<AppData>(load());

function persist() {
  if (typeof localStorage === 'undefined') return;
  localStorage.setItem(
    STORAGE_KEY,
    JSON.stringify({
      entries: app.entries,
      letters: app.letters,
      settings: app.settings
    })
  );
}

function id(): string {
  if (typeof crypto !== 'undefined' && 'randomUUID' in crypto) {
    return crypto.randomUUID();
  }
  return `${Date.now().toString(36)}-${Math.random().toString(36).slice(2, 9)}`;
}

export function addEntry(input: {
  content: string;
  mood?: MoodId;
  oneThing?: string;
  win?: string;
}): Entry {
  const entry: Entry = {
    id: id(),
    content: input.content,
    createdAt: new Date().toISOString(),
    mood: input.mood,
    oneThing: input.oneThing?.trim() || undefined,
    win: input.win?.trim() || undefined
  };
  app.entries = [entry, ...app.entries];
  persist();
  return entry;
}

export function updateEntry(
  entryId: string,
  patch: Partial<Pick<Entry, 'content' | 'mood' | 'oneThing' | 'win'>>
) {
  app.entries = app.entries.map((entry) =>
    entry.id === entryId ? { ...entry, ...patch } : entry
  );
  persist();
}

export function deleteEntry(entryId: string) {
  app.entries = app.entries.filter((entry) => entry.id !== entryId);
  persist();
}

export function saveLetter(input: {
  content: string;
  periodStart: string;
  periodEnd: string;
}): Letter {
  const letter: Letter = {
    id: id(),
    content: input.content,
    periodStart: input.periodStart,
    periodEnd: input.periodEnd,
    createdAt: new Date().toISOString(),
    kind: 'local'
  };
  app.letters = [letter, ...app.letters];
  persist();
  return letter;
}

export function setSetting<K extends keyof Settings>(key: K, value: Settings[K]) {
  app.settings[key] = value;
  persist();
}

export function clearJournal() {
  app.entries = [];
  app.letters = [];
  persist();
}

export function exportJson(): string {
  return JSON.stringify(
    {
      app: 'smriti',
      version: 1,
      exportedAt: new Date().toISOString(),
      entries: app.entries,
      letters: app.letters,
      settings: app.settings
    },
    null,
    2
  );
}

export function seedDemo() {
  const now = Date.now();
  const day = 24 * 60 * 60 * 1000;
  app.entries = [
    {
      id: id(),
      content:
        'Work was fine until the afternoon. I kept opening the invoice tab and closing it again. Went for a walk at six; that helped more than I expected.',
      createdAt: new Date(now - 2 * 60 * 60 * 1000).toISOString(),
      mood: 'low',
      oneThing: 'Send one invoice',
      win: 'Opened the invoice'
    },
    {
      id: id(),
      content:
        'Slept badly. Did the small version of the thing instead of the big version. It still counted.',
      createdAt: new Date(now - day).toISOString(),
      mood: 'okay',
      oneThing: 'Ten minutes on the deck',
      win: 'Did the small version'
    },
    {
      id: id(),
      content:
        'Good day. Walked before noon, ate lunch away from the desk, and the invoice finally went out.',
      createdAt: new Date(now - 2 * day).toISOString(),
      mood: 'good',
      oneThing: 'Invoice after the walk',
      win: 'Invoice sent'
    }
  ];
  persist();
}
