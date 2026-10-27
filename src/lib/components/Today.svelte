<script lang="ts">
  import { ArrowRight, Bell, CircleHelp, Flame, Mic, Moon, Sparkles } from 'lucide-svelte';
  import EntryCard from '$lib/components/EntryCard.svelte';
  import VoiceSession from '$lib/components/VoiceSession.svelte';
  import { modelState } from '$lib/model.svelte';
  import { app, seedDemo } from '$lib/state.svelte';
  import type { VoiceIntent } from '$lib/types';
  import { computeWeekStats, formatDate, lastSevenDays } from '$lib/weekly';

  let {
    onOpenJournal,
    onOpenSettings,
    onOpenWeekly
  }: {
    onOpenJournal: () => void;
    onOpenSettings: () => void;
    onOpenWeekly: () => void;
  } = $props();

  let voiceIntent = $state<VoiceIntent | null>(null);

  const recent = $derived(app.entries.slice(0, 3));
  const momentum = $derived(computeWeekStats(lastSevenDays(app.entries)));
  const isSunday = new Date().getDay() === 0;

  function greeting(): string {
    const hour = new Date().getHours();
    if (hour < 5) return 'Still up?';
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

  <div class="card voice-home-card mt-4">
    <p class="card-label">Voice check-in</p>
    <h2 class="voice-home-title">What's on your mind?</h2>
    <button
      class="voice-orb voice-orb-home"
      onclick={() => (voiceIntent = 'talk')}
      aria-label="Start voice check-in"
    >
      <Mic size={30} />
    </button>
    <p class="small">Tap, talk, and I'll ask the next question.</p>

    <div class="voice-doors">
      <button class="chip" onclick={() => (voiceIntent = 'stuck')}>
        <CircleHelp size={13} /> I'm stuck
      </button>
      <button class="chip" onclick={() => (voiceIntent = 'remember')}>
        <Bell size={13} /> Remember
      </button>
      <button class="chip" onclick={() => (voiceIntent = 'winddown')}>
        <Moon size={13} /> Wind down
      </button>
    </div>
  </div>

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
      <div class="empty-icon"><Mic size={20} /></div>
      <div>
        <p class="empty-title">Nothing yet.</p>
        <p class="empty-body">Tap the mic. Say one line. That counts.</p>
        <button class="link-btn" onclick={seedDemo}>See a sample week</button>
      </div>
    </div>
  {:else}
    {#each recent as entry (entry.id)}
      <EntryCard {entry} />
    {/each}
  {/if}
</div>

{#if voiceIntent}
  <VoiceSession intent={voiceIntent} onClose={() => (voiceIntent = null)} />
{/if}
