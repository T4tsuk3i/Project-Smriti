import { moodById } from './moods';
import type { DayBar, Entry, WeekStats } from './types';

export function wordCount(value: string): number {
  const text = value.trim();
  if (!text) return 0;
  return text.split(/\s+/).filter(Boolean).length;
}

export function dayKey(value: Date | string): string {
  const date = typeof value === 'string' ? new Date(value) : value;
  return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(
    date.getDate()
  ).padStart(2, '0')}`;
}

export function lastSevenDays(entries: Entry[], now = new Date()): Entry[] {
  const start = new Date(now.getFullYear(), now.getMonth(), now.getDate() - 6);
  return entries.filter((entry) => new Date(entry.createdAt) >= start);
}

export function computeWeekStats(entries: Entry[], now = new Date()): WeekStats {
  const start = new Date(now.getFullYear(), now.getMonth(), now.getDate() - 6);
  const bars: DayBar[] = [];

  for (let i = 0; i < 7; i += 1) {
    const date = new Date(start.getFullYear(), start.getMonth(), start.getDate() + i);
    const key = dayKey(date);
    const sameDay = entries.filter((entry) => dayKey(entry.createdAt) === key);
    bars.push({
      date,
      label: new Intl.DateTimeFormat(undefined, { weekday: 'short' }).format(date),
      words: sameDay.reduce((sum, entry) => sum + wordCount(entry.content), 0),
      wrote: sameDay.length > 0,
      mood: sameDay.find((entry) => entry.mood)?.mood
    });
  }

  const moods: Record<string, number> = {};
  for (const entry of entries) {
    if (entry.mood) moods[entry.mood] = (moods[entry.mood] ?? 0) + 1;
  }

  return {
    entries: entries.length,
    words: entries.reduce((sum, entry) => sum + wordCount(entry.content), 0),
    days: new Set(entries.map((entry) => dayKey(entry.createdAt))).size,
    bars,
    moods
  };
}

export function buildWeeklySummary(entries: Entry[]): string {
  if (entries.length === 0) return 'Nothing to sum up yet.';

  const days = new Set(entries.map((entry) => dayKey(entry.createdAt)));
  const words = new Map<string, number>();

  for (const entry of entries) {
    for (const match of entry.content.toLowerCase().matchAll(/[a-z']+/g)) {
      const word = match[0].replace(/^'+|'+$/g, '');
      if (word.length < 4 || STOP_WORDS.has(word)) continue;
      words.set(word, (words.get(word) ?? 0) + 1);
    }
  }

  const topWords = [...words.entries()]
    .filter(([, count]) => count > 1)
    .sort((a, b) => b[1] - a[1])
    .slice(0, 6)
    .map(([word]) => word);

  const longest = entries.reduce((a, b) =>
    a.content.length >= b.content.length ? a : b
  );

  const dayCounts = new Map<string, number>();
  for (const entry of entries) {
    const label = new Intl.DateTimeFormat(undefined, { weekday: 'long' }).format(
      new Date(entry.createdAt)
    );
    dayCounts.set(label, (dayCounts.get(label) ?? 0) + 1);
  }
  const busiest = [...dayCounts.entries()].sort((a, b) => b[1] - a[1])[0];

  const lines = ['This week', ''];

  if (entries.length === 1) {
    lines.push('You wrote once.');
  } else {
    lines.push(
      `You wrote ${entries.length} times, on ${days.size} ${
        days.size === 1 ? 'day' : 'different days'
      }.`
    );
  }

  if (topWords.length > 0) {
    lines.push('', `Words you came back to: ${topWords.join(', ')}.`);
  }

  lines.push('', `Your longest entry was ${longest.content.trim().length} characters.`);

  if (busiest && busiest[1] > 1) {
    lines.push(`Most of your writing happened on ${busiest[0]}.`);
  }

  lines.push(
    '',
    'That is it. No model read this — it is just a count of what you wrote.'
  );

  return lines.join('\n').trim();
}

export function moodLabel(id: string): string {
  return moodById(id)?.label ?? id;
}

export function formatDate(value: string | Date): string {
  const date = typeof value === 'string' ? new Date(value) : value;
  return new Intl.DateTimeFormat(undefined, {
    weekday: 'long',
    day: 'numeric',
    month: 'long'
  }).format(date);
}

export function formatShortDate(value: string | Date): string {
  const date = typeof value === 'string' ? new Date(value) : value;
  return new Intl.DateTimeFormat(undefined, {
    day: 'numeric',
    month: 'short'
  }).format(date);
}

export function formatTime(value: string | Date): string {
  const date = typeof value === 'string' ? new Date(value) : value;
  return new Intl.DateTimeFormat(undefined, {
    hour: 'numeric',
    minute: '2-digit'
  }).format(date);
}

export function periodLabel(start: string, end: string): string {
  return `${formatShortDate(start)} – ${formatShortDate(end)}`;
}

const STOP_WORDS = new Set([
  'about',
  'after',
  'again',
  'also',
  'and',
  'another',
  'anything',
  'because',
  'been',
  'before',
  'being',
  'between',
  'could',
  'does',
  'doing',
  'down',
  'during',
  'each',
  'even',
  'ever',
  'every',
  'feel',
  'felt',
  'from',
  'have',
  'having',
  'here',
  'into',
  'just',
  'like',
  'little',
  'made',
  'make',
  'many',
  'more',
  'most',
  'much',
  'myself',
  'never',
  'only',
  'other',
  'over',
  'really',
  'should',
  'some',
  'something',
  'still',
  'such',
  'than',
  'that',
  'their',
  'them',
  'then',
  'there',
  'these',
  'they',
  'thing',
  'think',
  'this',
  'through',
  'today',
  'very',
  'want',
  'were',
  'what',
  'when',
  'where',
  'which',
  'while',
  'with',
  'would',
  'your'
]);
