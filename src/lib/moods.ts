import type { MoodId } from './types';

export interface Mood {
  id: MoodId;
  label: string;
  emoji: string;
  color: string;
  soft: string;
}

export const MOODS: Mood[] = [
  { id: 'good', label: 'Good', emoji: '😊', color: '#7E9F6B', soft: '#E6EFDB' },
  { id: 'okay', label: 'Okay', emoji: '🙂', color: '#D9A93E', soft: '#FBF0CE' },
  { id: 'low', label: 'Low', emoji: '😕', color: '#D9823F', soft: '#FBE6D2' },
  { id: 'heavy', label: 'Heavy', emoji: '😞', color: '#D95F32', soft: '#FBE0D4' },
  { id: 'numb', label: 'Numb', emoji: '😐', color: '#9278B8', soft: '#EFE7F8' }
];

export function moodById(id?: MoodId | string | null): Mood | undefined {
  if (!id) return undefined;
  return MOODS.find((mood) => mood.id === id);
}
