import { invoke } from '@tauri-apps/api/core';
import { open } from '@tauri-apps/plugin-dialog';

export interface ModelStatus {
  configured: boolean;
  provider: 'edge' | 'api' | 'none';
  path?: string | null;
  name?: string | null;
  size_bytes?: number | null;
  base_url?: string | null;
  model?: string | null;
  has_api_key: boolean;
  message: string;
}

export const modelState = $state<{
  status: ModelStatus | null;
  loading: boolean;
  error: string;
}>({
  status: null,
  loading: false,
  error: ''
});

export function inTauri(): boolean {
  return typeof window !== 'undefined' && '__TAURI_INTERNALS__' in window;
}

export async function refreshModel(): Promise<ModelStatus | null> {
  if (!inTauri()) {
    modelState.status = null;
    return null;
  }

  modelState.loading = true;
  modelState.error = '';
  try {
    const status = await invoke<ModelStatus>('model_status');
    modelState.status = status;
    return status;
  } catch (error) {
    modelState.error = error instanceof Error ? error.message : String(error);
    return null;
  } finally {
    modelState.loading = false;
  }
}

export async function chooseModel(): Promise<ModelStatus | null> {
  if (!inTauri()) return null;

  modelState.loading = true;
  modelState.error = '';
  try {
    const selected = await open({
      multiple: false,
      directory: false,
      filters: [{ name: 'GGUF model', extensions: ['gguf'] }]
    });

    if (!selected || Array.isArray(selected)) return null;

    const status = await invoke<ModelStatus>('set_model_path', { path: selected });
    modelState.status = status;
    return status;
  } catch (error) {
    modelState.error = error instanceof Error ? error.message : String(error);
    return null;
  } finally {
    modelState.loading = false;
  }
}

export async function saveApiModel(
  baseUrl: string,
  model: string,
  apiKey: string
): Promise<ModelStatus | null> {
  if (!inTauri()) return null;

  modelState.loading = true;
  modelState.error = '';
  try {
    const status = await invoke<ModelStatus>('set_api_model', {
      baseUrl,
      model,
      apiKey: apiKey.trim() || null
    });
    modelState.status = status;
    return status;
  } catch (error) {
    modelState.error = error instanceof Error ? error.message : String(error);
    return null;
  } finally {
    modelState.loading = false;
  }
}

export async function testApiModel(
  baseUrl: string,
  model: string,
  apiKey: string
): Promise<string> {
  if (!inTauri()) return 'API test is available in the Android app.';
  return await invoke<string>('test_api_model', {
    baseUrl,
    model,
    apiKey: apiKey.trim() || null
  });
}

export async function removeModel(): Promise<ModelStatus | null> {
  if (!inTauri()) return null;

  modelState.loading = true;
  modelState.error = '';
  try {
    const status = await invoke<ModelStatus>('clear_model');
    modelState.status = status;
    return status;
  } catch (error) {
    modelState.error = error instanceof Error ? error.message : String(error);
    return null;
  } finally {
    modelState.loading = false;
  }
}

export function formatModelSize(bytes?: number | null): string {
  if (!bytes) return '';
  const mb = bytes / (1024 * 1024);
  if (mb >= 1024) return `${(mb / 1024).toFixed(1)} GB`;
  return `${Math.round(mb)} MB`;
}
