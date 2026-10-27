import {
  cancelAll,
  isPermissionGranted,
  pending,
  requestPermission,
  Schedule,
  sendNotification
} from '@tauri-apps/plugin-notification';
import { inTauri } from './model.svelte';

export const reminderState = $state<{
  enabled: boolean;
  loading: boolean;
  error: string;
}>({
  enabled: false,
  loading: false,
  error: ''
});

export async function scheduleReminders(time: string): Promise<boolean> {
  if (!inTauri()) {
    reminderState.error = 'Notifications are available in the app.';
    return false;
  }

  reminderState.loading = true;
  reminderState.error = '';

  try {
    let granted = await isPermissionGranted();
    if (!granted) {
      granted = (await requestPermission()) === 'granted';
    }
    if (!granted) {
      reminderState.enabled = false;
      reminderState.error = 'Notifications are blocked. Enable them in Android settings.';
      return false;
    }

    await cancelAll();

    const [hour, minute] = time.split(':').map(Number);
    if (Number.isNaN(hour) || Number.isNaN(minute)) {
      reminderState.error = 'Pick a valid time.';
      return false;
    }

    sendNotification({
      title: 'Smriti',
      body: 'One line about today? That counts.',
      schedule: Schedule.interval({ hour, minute }, true)
    });

    sendNotification({
      title: 'Smriti',
      body: 'Sunday. Want the week in words?',
      schedule: Schedule.interval({ weekday: 1, hour: 10, minute: 0 }, true)
    });

    reminderState.enabled = true;
    return true;
  } catch (error) {
    reminderState.enabled = false;
    reminderState.error = error instanceof Error ? error.message : String(error);
    return false;
  } finally {
    reminderState.loading = false;
  }
}

export async function clearReminders(): Promise<void> {
  if (!inTauri()) return;
  await cancelAll();
  reminderState.enabled = false;
}

export async function refreshReminderState(): Promise<void> {
  if (!inTauri()) return;
  try {
    const scheduled = await pending();
    reminderState.enabled = scheduled.length > 0;
  } catch {
    reminderState.enabled = false;
  }
}
