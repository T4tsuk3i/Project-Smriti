<script lang="ts">
  import { ArrowRight, CircleHelp, Sparkles } from 'lucide-svelte';
  import EntryCard from '$lib/components/EntryCard.svelte';
  import MoodPicker from '$lib/components/MoodPicker.svelte';
  import { checkSafety } from '$lib/safety';
  import { addEntry, app, seedDemo } from '$lib/state.svelte';
  import type { MoodId, SafetyCheck } from '$lib/types';
  import { formatDate, wordCount } from '$lib/weekly';

  let {
    onOpenJournal,
    onOpenSettings,
    onStuck
  }: {
    onOpenJournal: () => void;
    onOpenSettings: () => void;
    onStuck: () => void;
  } = $props();

  let text = $state('');
  let oneThing = $state('');
  let mood = $state<MoodId | undefined>(undefined);
  let safety = $state<SafetyCheck | null>(null);
  let saved = $state(false);

  const words = $derived(wordCount(text));
  const recent = $derived(app.entries.slice(0, 3));

  function greeting(): string {
    const hour = new Date().getHours();
    const base =
      hour < 12
        ? 'Good morning'
        : hour < 17
          ? 'Good afternoon'
          : hour < 22
            ? 'Good evening'
            : 'Still up?';
    if (base === 'Still up?') return base;
    return app.settings.userName
      ? `${base}, ${app.settings.userName}.`
      : `${base}.`;
  }

  function save() {
    const value = text.trim();
    if (!value) return;

    const check = checkSafety(value, app.settings.country);
    addEntry({ content: value, mood, oneThing });
    text = '';
    oneThing = '';
    mood = undefined;
    safety = check.flagged ? check : null;
    saved = true;
    setTimeout(() => (saved = false), 2200);
  }
</script>

<div class="page">
  <h1 class="greeting">{greeting()}</h1>
  <p class="date">{formatDate(new Date())}</p>

  <div class="card mt-4">
    <p class="card-title">How are you arriving?</p>
    <MoodPicker value={mood} onChange={(next) => (mood = next)} />
    <div class="one-thing">
      <span class="icon"><Sparkles size={16} /></span>
      <input bind:value={oneThing} maxlength="120" placeholder="One thing that would make today feel okay" />
    </div>
  </div>

  <div class="card">
    <textarea
      class="textarea"
      bind:value={text}
      maxlength="12000"
      placeholder="What's on your mind?"
      aria-label="Journal entry"
    ></textarea>
    <div class="write-footer">
      <span class="word-count">
        {words} {words === 1 ? 'word' : 'words'}{saved ? ' · saved' : ''}
      </span>
      <button class="btn" onclick={save} disabled={!text.trim()}>Save</button>
    </div>
  </div>

  {#if safety}
    <div class="safety">
      <p class="safety-title">That sounds heavy.</p>
      <p>
        If you might be in danger, please call a local helpline or emergency
        services. Smriti cannot monitor you or call anyone for you.
      </p>
      <ul>
        {#each safety.resources as resource (resource.label)}
          <li>{resource.label} — {resource.contact}</li>
        {/each}
      </ul>
    </div>
  {/if}

  <button class="btn soft big" onclick={onStuck}>
    <CircleHelp size={16} />
    Stuck? Start smaller
  </button>

  <div class="notice mt-4">
    <span class="notice-icon"><Sparkles size={17} /></span>
    <div>
      <p class="notice-title">Reflection is off</p>
      <p class="notice-body">
        No model on this phone yet. Writing works; the reflective parts wait
        until one is set up.
      </p>
    </div>
    <button class="link-btn" onclick={onOpenSettings}>Details</button>
  </div>

  <div class="section-head">
    <h2 class="section-title">Lately</h2>
    {#if recent.length > 0}
      <button class="link-btn" onclick={onOpenJournal}>
        See all <ArrowRight size={13} style="vertical-align: -2px" />
      </button>
    {/if}
  </div>

  {#if recent.length === 0}
    <div class="empty-card">
      <div class="empty-icon"><Sparkles size={20} /></div>
      <div>
        <p class="empty-title">Blank page.</p>
        <p class="empty-body">Write one line. That counts.</p>
        <button class="link-btn" onclick={seedDemo}>See a sample week</button>
      </div>
    </div>
  {:else}
    {#each recent as entry (entry.id)}
      <EntryCard {entry} />
    {/each}
  {/if}
</div>
