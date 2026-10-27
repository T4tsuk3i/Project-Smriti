<script lang="ts">
  import { Check, Search, Sparkles } from 'lucide-svelte';
  import EditEntrySheet from '$lib/components/EditEntrySheet.svelte';
  import EntryCard from '$lib/components/EntryCard.svelte';
  import { app, deleteEntry, seedDemo } from '$lib/state.svelte';
  import type { Entry } from '$lib/types';
  import { computeWeekStats, lastSevenDays } from '$lib/weekly';

  let query = $state('');
  let editing = $state<Entry | null>(null);

  const weekEntries = $derived(lastSevenDays(app.entries));
  const stats = $derived(computeWeekStats(weekEntries));
  const filtered = $derived(
    app.entries.filter((entry) => {
      if (!query.trim()) return true;
      const needle = query.toLowerCase();
      return (
        entry.content.toLowerCase().includes(needle) ||
        entry.oneThing?.toLowerCase().includes(needle) ||
        entry.mood?.toLowerCase().includes(needle)
      );
    })
  );

  function remove(entry: Entry) {
    if (confirm('Delete this entry? It will not come back.')) {
      deleteEntry(entry.id);
    }
  }
</script>

<div class="page">
  <h1 class="greeting">Journal</h1>
  <p class="subtitle">
    {app.entries.length} {app.entries.length === 1 ? 'entry' : 'entries'}, newest first.
  </p>

  <div class="card mt-4">
    <p class="card-label">This week</p>
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
    <div class="dots">
      {#each stats.bars as day (day.label + day.date.toISOString())}
        <div class="dot-col">
          <div class="dot" class:done={day.wrote}>
            {#if day.wrote}<Check size={13} />{/if}
          </div>
          <span class="dot-label">{day.label.substring(0, 1)}</span>
        </div>
      {/each}
    </div>
  </div>

  <div class="search">
    <span class="search-icon"><Search size={17} /></span>
    <input bind:value={query} placeholder="Search your entries" aria-label="Search entries" />
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
        <p class="empty-title">Nothing matches.</p>
        <p class="empty-body">Try a different word, or clear the search.</p>
      </div>
    </div>
  {:else}
    {#each filtered as entry (entry.id)}
      <EntryCard {entry} onEdit={() => (editing = entry)} onDelete={() => remove(entry)} />
    {/each}
  {/if}
</div>

{#if editing}
  <EditEntrySheet entry={editing} onClose={() => (editing = null)} />
{/if}
