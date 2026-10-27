<script lang="ts">
  import MoodPicker from '$lib/components/MoodPicker.svelte';
  import { updateEntry } from '$lib/state.svelte';
  import type { Entry, MoodId } from '$lib/types';

  let {
    entry,
    onClose
  }: {
    entry: Entry;
    onClose: () => void;
  } = $props();

  // svelte-ignore state_referenced_locally
  let text = $state(entry.content);
  // svelte-ignore state_referenced_locally
  let oneThing = $state(entry.oneThing ?? '');
  // svelte-ignore state_referenced_locally
  let mood = $state<MoodId | undefined>(entry.mood);

  function save() {
    const value = text.trim();
    if (!value) return;
    updateEntry(entry.id, {
      content: value,
      oneThing: oneThing.trim() || undefined,
      mood
    });
    onClose();
  }
</script>

<div
  class="sheet-backdrop"
  role="presentation"
  onclick={onClose}
>
  <div
    class="sheet"
    role="dialog"
    tabindex="-1"
    aria-modal="true"
    aria-label="Edit entry"
    onclick={(event) => event.stopPropagation()}
    onkeydown={(event) => event.stopPropagation()}
  >
    <div class="sheet-handle"></div>
    <h2 class="sheet-title">Edit entry</h2>
    <p class="sheet-body">Change the words, the mood, or the one thing. Nothing else changes.</p>

    <div class="mt-3">
      <MoodPicker value={mood} onChange={(next) => (mood = next)} />
    </div>

    <textarea
      class="textarea"
      bind:value={text}
      maxlength="12000"
      placeholder="What's on your mind?"
      aria-label="Entry text"
    ></textarea>

    <input
      class="field mt-2"
      bind:value={oneThing}
      maxlength="120"
      placeholder="One thing that would make today feel okay"
      aria-label="One thing"
    />

    <div class="row mt-3">
      <button class="btn ghost" onclick={onClose}>Cancel</button>
      <div class="spacer"></div>
      <button class="btn" onclick={save} disabled={!text.trim()}>Save changes</button>
    </div>
  </div>
</div>
