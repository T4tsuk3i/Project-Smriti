<script lang="ts">
  import { ArrowRight, CircleHelp, Flame, Sparkles, Target } from 'lucide-svelte';
  import EntryCard from '$lib/components/EntryCard.svelte';
  import MoodPicker from '$lib/components/MoodPicker.svelte';
  import { modelState } from '$lib/model.svelte';
  import { checkSafety } from '$lib/safety';
  import { addEntry, app, seedDemo } from '$lib/state.svelte';
  import type { MoodId, SafetyCheck } from '$lib/types';
  import {
    computeWeekStats,
    formatDate,
    lastSevenDays,
    wordCount
  } from '$lib/weekly';

  let {
    onOpenJournal,
    onOpenSettings,
    onOpenWeekly,
    onStuck
  }: {
    onOpenJournal: () => void;
    onOpenSettings: () => void;
    onOpenWeekly: () => void;
    onStuck: () => void;
  } = $props();

  let text = $state('');
  let oneThing = $state('');
  let win = $state('');
  let mood = $state<MoodId | undefined>(undefined);
  let safety = $state<SafetyCheck | null>(null);
  let saved = $state(false);
  let showOneThing = $state(false);
  let showWin = $state(false);

  const MOOD_NOTES: Record<MoodId, string> = {
    good: 'Good days are worth noticing.',
    okay: 'Okay is a real answer.',
    low: 'Low days still count.',
    heavy: 'Heavy is allowed here.',
    numb: 'Numb is information, not a failure.'
  };

  const words = $derived(wordCount(text));
  const recent = $derived(app.entries.slice(0, 3));
  const momentum = $derived(computeWeekStats(lastSevenDays(app.entries)));
  const moodNote = $derived(mood ? MOOD_NOTES[mood] : null);
  const isSunday = new Date().getDay() === 0;

  const prompts = [
    'What do you want to remember about today?',
    'What is taking up the most space in your head?',
    'What did you get through today?',
    'What would make today 10% easier?',
    'What is one thing you keep forgetting?'
  ];
  const prompt =
    prompts[Math.floor(new Date().setHours(0, 0, 0, 0) / 86_400_000) % prompts.length];

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
    addEntry({ content: value, mood, oneThing, win });
    text = '';
    oneThing = '';
    win = '';
    mood = undefined;
    showOneThing = false;
    showWin = false;
    safety = check.flagged ? check : null;
    saved = true;
    setTimeout(() => (saved = false), 2200);
  }
</script>

<div class="page">
  <div class="today-head">
    <div>
      <h1 class="greeting">{greeting()}</h1>
      <p class="date">{formatDate(new Date())}</p>
    </div>
    <div class="momentum" title="Days you showed up this week">
      <Flame size={14} />
      <span>{momentum.days} {momentum.days === 1 ? 'day' : 'days'} this week</span>
    </div>
  </div>

  {#if isSunday && app.entries.length > 0}
    <div class="weekly-nudge">
      <span class="weekly-icon"><Sparkles size={17} /></span>
      <div>
        <p class="weekly-title">Sunday. Want the week in words?</p>
        <p class="weekly-body">A two-minute look-back. No score.</p>
      </div>
      <button class="link-btn" onclick={onOpenWeekly}>Open</button>
    </div>
  {/if}

  <div class="card today-card mt-4">
    <div class="card-row">
      <p class="card-title">How's today?</p>
      <span class="small faint">No wrong answer</span>
    </div>

    <MoodPicker value={mood} onChange={(next) => (mood = next)} />
    {#if moodNote}
      <p class="mood-note">{moodNote}</p>
    {/if}

    <textarea
      class="textarea today-textarea"
      bind:value={text}
      maxlength="12000"
      placeholder={prompt}
      aria-label="Journal entry"
    ></textarea>

    <div class="write-footer">
      <span class="word-count">{words} {words === 1 ? 'word' : 'words'}</span>
      {#if saved}
        <span class="saved-pill"><Sparkles size={13} /> Saved. That counts.</span>
      {/if}
      <div class="spacer"></div>
      <button class="btn" onclick={save} disabled={!text.trim()}>Save</button>
    </div>

    <div class="extras-row">
      <button
        class="chip"
        class:active={showOneThing}
        onclick={() => (showOneThing = !showOneThing)}
      >
        <Target size={13} /> One thing
      </button>
      <button class="chip" class:active={showWin} onclick={() => (showWin = !showWin)}>
        <Sparkles size={13} /> Tiny win
      </button>
      <button class="chip" onclick={onStuck}>
        <CircleHelp size={13} /> Stuck
      </button>
    </div>

    {#if showOneThing}
      <input
        class="field extra-input one"
        bind:value={oneThing}
        maxlength="120"
        placeholder="One thing for today"
        aria-label="One thing for today"
      />
    {/if}
    {#if showWin}
      <input
        class="field extra-input win"
        bind:value={win}
        maxlength="120"
        placeholder="One tiny win"
        aria-label="One tiny win"
      />
    {/if}
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

  <div class="notice mt-3">
    <span class="notice-icon"><Sparkles size={17} /></span>
    <div>
      <p class="notice-title">
        {modelState.status?.configured ? 'Model file ready' : 'Reflection is off'}
      </p>
      <p class="notice-body">
        {#if modelState.status?.configured}
          Local inference is the next milestone. Writing works now, and nothing
          is uploaded.
        {:else}
          No model on this phone yet. Writing works; the reflective parts wait
          until one is set up.
        {/if}
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
