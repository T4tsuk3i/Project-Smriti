import { addPluginListener, invoke, type PluginListener } from '@tauri-apps/api/core';

export async function start(): Promise<void> {
  await invoke('plugin:speech|start');
}

export async function stop(): Promise<void> {
  await invoke('plugin:speech|stop');
}

export async function cancel(): Promise<void> {
  await invoke('plugin:speech|cancel');
}

export function onPartial(cb: (payload: { text: string }) => void): Promise<PluginListener> {
  return addPluginListener('speech', 'partial', cb);
}

export function onResult(cb: (payload: { text: string }) => void): Promise<PluginListener> {
  return addPluginListener('speech', 'result', cb);
}

export function onError(cb: (payload: { code: number; message: string }) => void): Promise<PluginListener> {
  return addPluginListener('speech', 'error', cb);
}

export function onLevel(cb: (payload: { value: number }) => void): Promise<PluginListener> {
  return addPluginListener('speech', 'level', cb);
}

export function onSpeechStart(cb: () => void): Promise<PluginListener> {
  return addPluginListener('speech', 'speechstart', cb);
}

export function onSpeechEnd(cb: () => void): Promise<PluginListener> {
  return addPluginListener('speech', 'speechend', cb);
}
