<script lang="ts">
  import { PenLine, Search, Sparkles } from 'lucide-svelte';
  import EditEntrySheet from '$lib/components/EditEntrySheet.svelte';
  import EntryCard from '$lib/components/EntryCard.svelte';
  import { moodById } from '$lib/moods';
  import { app, deleteEntry, seedDemo } from '$lib/state.svelte';
  import type { Entry } from '$lib/types';
  import { computeWeekStats, lastSevenDays } from '$lib/weekly';

  let {
    onWrite
  }: {
    onWrite: () => void;
  } = $props();

  type Filter = 'all' | 'wins' | 'moods';
  let query = $state('');
  let filter = $state<Filter>('all');
  let editing = $state<Entry | null>(null);

  const weekEntries = $derived(lastSevenDays(app.entries));
  const stats = $derived(computeWeekStats(weekEntries));
  const filtered = $derived(
    app.entries.filter((entry) => {
      if (filter === 'wins' && !entry.win) return false;
      if (filter === 'moods' && !entry.mood) return false;
      if (!query.trim()) return true;
      const needle = query.toLowerCase();
      return (
        entry.content.toLowerCase().includes(needle) ||
        entry.oneThing?.toLowerCase().includes(needle) ||
        entry.win?.toLowerCase().includes(needle) ||
        entry.mood?.toLowerCase().includes(needle)
      );
    })
  );

  function remove(entry: Entry) {
    if (confirm('Delete this entry? It will not come back.')) {
      deleteEntry(entry.id);
    }
  }

  function isToday(date: Date): boolean {
    return date.toDateString() === new Date().toDateString();
  }
</script>

<div class="page">
  <h1 class="greeting">Journal</h1>
  <p class="subtitle">
    {app.entries.length} {app.entries.length === 1 ? 'entry' : 'entries'}, newest first.
  </p>

  <div class="segmented mt-3">
    <button class:active={filter === 'all'} onclick={() => (filter = 'all')}>All</button>
    <button class:active={filter === 'wins'} onclick={() => (filter = 'wins')}>Wins</button>
    <button class:active={filter === 'moods'} onclick={() => (filter = 'moods')}>Moods</button>
  </div>

  <div class="card mt-3">
    <div class="row">
      <p class="card-label">This week</p>
      <div class="spacer"></div>
      <span class="small faint">{stats.entries} check-ins</span>
    </div>
    <div class="stats-grid mt-2">
      <div class="stat" style="--stat-color: var(--rust)">
        <p class="stat-value">{stats.entries}</p>
        <p class="stat-label">entries</p>
      </div>
      <div class="stat" style="--stat-color: var(--lilac)">
        <p class="stat-value">{stats.words}</p>
        <p class="stat-label">words</p>
      </div>
      <div class="stat" style="--stat-color: var(--sage)">
        <p class="stat-value">{stats.days}</p>
        <p class="stat-label">days</p>
      </div>
    </div>

    <div class="date-strip">
      {#each stats.bars as day (day.label + day.date.toISOString())}
        {@const dayMood = moodById(day.mood)}
        <div
          class="date-pill"
          class:today={isToday(day.date)}
          class:done={day.wrote}
          aria-label={`${day.label} ${day.date.getDate()}${dayMood ? `, ${dayMood.label}` : ''}`}
        >
          <span class="weekday">{day.label.substring(0, 1)}</span>
          <span class="daynum">{day.date.getDate()}</span>
          <span class="daymood">{dayMood?.emoji ?? (day.wrote ? '•' : '')}</span>
        </div>
      {/each}
    </div>
  </div>

  <div class="search">
    <span class="search-icon"><Search size={17} /></span>
    <input bind:value={query} placeholder="Search entries, wins, moods" aria-label="Search entries" />
  </div>

  {#if app.entries.length === 0}
    <div class="empty-card">
      <div class="empty-icon"><Sparkles size={20} /></div>
      <div>
        <p class="empty-title">Blank page.</p>
        <p class="empty-body">Write a check-in first. One line is enough.</p>
        <button class="link-btn" onclick={seedDemo}>See a sample week</button>
      </div>
    </div>
  {:else if filtered.length === 0}
    <div class="empty-card">
      <div class="empty-icon"><Search size={20} /></div>
      <div>
        <p class="empty-title">Nothing here.</p>
        <p class="empty-body">Try another filter or clear the search.</p>
        <button class="link-btn" onclick={() => { filter = 'all'; query = ''; }}>Show all</button>
      </div>
    </div>
  {:else}
    {#each filtered as entry (entry.id)}
      <EntryCard
        {entry}
        onEdit={() => (editing = entry)}
        onDelete={() => remove(entry)}
      />
    {/each}
  {/if}
</div>

<button class="fab" onclick={onWrite} aria-label="Write a check-in">
  <PenLine size={22} />
</button>

{#if editing}
  <EditEntrySheet entry={editing} onClose={() => (editing = null)} />
{/if}
