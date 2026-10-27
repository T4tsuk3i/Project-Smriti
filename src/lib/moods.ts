import type { MoodId } from './types';

export interface Mood {
  id: MoodId;
  label: string;
  emoji: string;
  color: string;
  soft: string;
}

export const MOODS: Mood[] = [
  { id: 'good', label: 'Good', emoji: '😊', color: '#1FBFAE', soft: '#DDF7F2' },
  { id: 'okay', label: 'Okay', emoji: '🙂', color: '#E2B53B', soft: '#FFF4CF' },
  { id: 'low', label: 'Low', emoji: '😕', color: '#FF9F43', soft: '#FFEEDA' },
  { id: 'heavy', label: 'Heavy', emoji: '😞', color: '#EF4F86', soft: '#FDE3EC' },
  { id: 'numb', label: 'Numb', emoji: '😐', color: '#A78BFA', soft: '#EFE9FF' }
];

export function moodById(id?: MoodId | string | null): Mood | undefined {
  if (!id) return undefined;
  return MOODS.find((mood) => mood.id === id);
}
