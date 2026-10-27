<script lang="ts">
  import { onMount } from 'svelte';
  import {
    Bell,
    Brain,
    ChevronDown,
    Copy,
    FolderOpen,
    Heart,
    Info,
    Sparkles,
    Trash2
  } from 'lucide-svelte';
  import { invoke } from '@tauri-apps/api/core';
  import {
    app,
    clearJournal,
    exportJson,
    seedDemo,
    setSetting
  } from '$lib/state.svelte';
  import {
    chooseModel,
    formatModelSize,
    inTauri,
    modelState,
    refreshModel,
    removeModel
  } from '$lib/model.svelte';
  import {
    clearReminders,
    refreshReminderState,
    reminderState,
    scheduleReminders
  } from '$lib/reminders.svelte';

  let rustVersion = $state('web preview');
  let copied = $state(false);

  onMount(async () => {
    void refreshModel();
    void refreshReminderState();
    try {
      rustVersion = await invoke<string>('core_version');
    } catch {
      rustVersion = 'web preview';
    }
  });

  async function setReminder(value: string) {
    setSetting('reminderTime', value);
    if (!inTauri()) return;
    await scheduleReminders(value);
  }

  async function copyExport() {
    await navigator.clipboard.writeText(exportJson());
    copied = true;
    setTimeout(() => (copied = false), 1800);
  }

  function clearAll() {
    if (confirm('Delete every entry and summary on this phone? Settings stay.')) {
      clearJournal();
    }
  }
</script>

<div class="page">
  <h1 class="greeting">Settings</h1>
  <p class="subtitle">Small app. Local by default.</p>

  <div class="settings-card lilac mt-4">
    <div class="settings-head">
      <div class="settings-icon" style="--icon-color: var(--lilac)"><Brain size={19} /></div>
      <h2 class="settings-title">Model</h2>
      <div class="spacer"></div>
      <span class="status-pill">{modelState.status?.configured ? 'Ready' : 'Not set up'}</span>
    </div>

    {#if modelState.status?.configured}
      <p class="small" style="font-weight: 700">
        {modelState.status.name ?? 'Local model'}
        {#if modelState.status.size_bytes}
          · {formatModelSize(modelState.status.size_bytes)}
        {/if}
      </p>
      <p class="small mt-2">
        The model file is registered on this phone. Local inference is the next
        milestone; no cloud is involved.
      </p>
      <div class="row wrap mt-2">
        <button class="btn soft" onclick={chooseModel} disabled={modelState.loading}>
          Change model
        </button>
        <button class="btn danger" onclick={removeModel} disabled={modelState.loading}>
          Remove
        </button>
      </div>
    {:else}
      <p class="small">
        Pick a GGUF model stored on this phone. Writing works without one, and
        nothing is downloaded or sent anywhere.
      </p>
      <button class="btn soft mt-2" onclick={chooseModel} disabled={modelState.loading || !inTauri()}>
        {modelState.loading ? 'Opening…' : 'Choose model file'}
      </button>
      {#if !inTauri()}
        <p class="small mt-2" style="color: var(--faint)">
          File picker is available in the Android app. Browser preview cannot
          read model files.
        </p>
      {/if}
      <p class="small mt-2" style="color: var(--faint)">
        The file stays on the device. Inference will run locally; no server, no
        upload.
      </p>
    {/if}

    {#if modelState.error}
      <p class="small mt-2" style="color: var(--danger)">{modelState.error}</p>
    {/if}
  </div>

  <div class="settings-card sage">
    <div class="settings-head">
      <div class="settings-icon" style="--icon-color: var(--sage)"><Heart size={19} /></div>
      <h2 class="settings-title">Support</h2>
    </div>
    <p class="small">
      Used only to show the right helplines if something you write looks like a
      crisis. Smriti cannot call anyone for you.
    </p>
    <div class="select-wrap mt-2">
      <select
        value={app.settings.country}
        onchange={(event) => setSetting('country', event.currentTarget.value)}
        aria-label="Support country"
      >
        <option value="IN">India</option>
        <option value="US">United States</option>
        <option value="GB">United Kingdom</option>
        <option value="CA">Canada</option>
        <option value="AU">Australia</option>
        <option value="OTHER">Other / international</option>
      </select>
      <span class="chev"><ChevronDown size={17} /></span>
    </div>
  </div>

  <div class="settings-card butter">
    <div class="settings-head">
      <div class="settings-icon" style="--icon-color: var(--butter)"><Bell size={19} /></div>
      <h2 class="settings-title">Reminders</h2>
    </div>
    <p class="small">
      One nudge a day at this time, plus a Sunday look-back. No streak warnings.
    </p>
    <input
      class="field mt-2"
      type="time"
      value={app.settings.reminderTime}
      onchange={(event) => setReminder(event.currentTarget.value)}
      aria-label="Reminder time"
    />
    <div class="row wrap mt-2">
      <span class="status-pill">
        {reminderState.enabled ? 'Reminder on' : 'Not scheduled'}
      </span>
      {#if reminderState.enabled}
        <button class="link-btn" onclick={clearReminders}>Turn off</button>
      {/if}
    </div>
    {#if reminderState.error}
      <p class="small mt-2" style="color: var(--danger)">{reminderState.error}</p>
    {/if}
  </div>

  <div class="settings-card orange">
    <div class="settings-head">
      <div class="settings-icon" style="--icon-color: var(--orange)"><FolderOpen size={19} /></div>
      <h2 class="settings-title">Data</h2>
    </div>
    <p class="small">
      {app.entries.length} {app.entries.length === 1 ? 'entry' : 'entries'} on this phone.
    </p>
    <div class="row wrap mt-2">
      <button class="btn soft" onclick={copyExport}>
        <Copy size={15} /> {copied ? 'Copied' : 'Copy export'}
      </button>
      <button class="btn danger" onclick={clearAll}>
        <Trash2 size={15} /> Delete everything
      </button>
    </div>
    {#if app.entries.length === 0}
      <button class="link-btn mt-2" onclick={seedDemo}>
        <Sparkles size={13} style="vertical-align: -2px" /> Load a sample week
      </button>
    {/if}
  </div>

  <div class="settings-card neutral">
    <div class="settings-head">
      <div class="settings-icon" style="--icon-color: var(--rust)"><Info size={19} /></div>
      <h2 class="settings-title">About</h2>
    </div>
    <p class="small">Smriti 0.1.0 · MIT</p>
    <p class="small mt-2">
      Built by one person. Android first; iOS when it is ready.
    </p>
    <p class="small mt-2">
      Rust core: {rustVersion} · Tauri 2 + Svelte
    </p>
    <p class="small mt-2" style="color: var(--faint)">
      Next: local model, encryption, app lock, home-screen widget.
    </p>
    <p class="small mt-2" style="font-weight: 700">
      No account. No server. No analytics.
    </p>
  </div>
</div>
