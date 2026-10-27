import { addPluginListener, invoke, type PluginListener } from '@tauri-apps/api/core';
import { inTauri } from './model.svelte';

export const speechState = $state<{
  listening: boolean;
  partial: string;
  level: number;
  error: string;
}>({
  listening: false,
  partial: '',
  level: 0,
  error: ''
});

let listeners: PluginListener[] = [];

function cleanup() {
  for (const listener of listeners) {
    listener.unregister();
  }
  listeners = [];
  speechState.listening = false;
  speechState.level = 0;
}

export async function cancelListening(): Promise<void> {
  if (!inTauri()) return;
  try {
    await invoke('plugin:speech|cancel');
  } catch {
    // The recognizer may already be stopped.
  }
  cleanup();
}

export async function startListening(): Promise<string> {
  if (!inTauri()) {
    throw new Error('Voice input is available in the Android app.');
  }

  await cancelListening();
  speechState.partial = '';
  speechState.error = '';
  speechState.listening = true;

  return new Promise<string>(async (resolve, reject) => {
    try {
      listeners.push(
        await addPluginListener('speech', 'partial', (payload: { text: string }) => {
          speechState.partial = payload.text;
        })
      );
      listeners.push(
        await addPluginListener('speech', 'result', (payload: { text: string }) => {
          const text = (payload.text ?? '').trim();
          cleanup();
          if (text) resolve(text);
          else reject(new Error("I didn't catch that. Try again."));
        })
      );
      listeners.push(
        await addPluginListener('speech', 'error', (payload: { message: string }) => {
          cleanup();
          speechState.error = payload.message ?? 'Speech recognition failed.';
          reject(new Error(speechState.error));
        })
      );
      listeners.push(
        await addPluginListener('speech', 'level', (payload: { value: number }) => {
          speechState.level = payload.value;
        })
      );

      await invoke('plugin:speech|start');
    } catch (error) {
      cleanup();
      reject(error instanceof Error ? error : new Error(String(error)));
    }
  });
}

export async function stopListening(): Promise<void> {
  if (!inTauri()) return;
  try {
    await invoke('plugin:speech|stop');
  } catch {
    // Ignore stop errors; the result event will settle the session.
  }
}
