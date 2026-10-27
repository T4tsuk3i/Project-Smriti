<script lang="ts">
  import { PenLine, Sparkles } from 'lucide-svelte';
  import { app, saveLetter } from '$lib/state.svelte';
  import {
    buildWeeklySummary,
    computeWeekStats,
    lastSevenDays,
    periodLabel
  } from '$lib/weekly';

  let saved = $state(false);

  const weekEntries = $derived(lastSevenDays(app.entries));
  const stats = $derived(computeWeekStats(weekEntries));
  const latest = $derived(app.letters[0]);
  const maxWords = $derived(Math.max(1, ...stats.bars.map((day) => day.words)));

  function writeItUp() {
    if (weekEntries.length === 0) return;
    const end = new Date();
    const start = new Date(end.getFullYear(), end.getMonth(), end.getDate() - 6);
    saveLetter({
      content: buildWeeklySummary(weekEntries),
      periodStart: start.toISOString(),
      periodEnd: end.toISOString()
    });
    saved = true;
    setTimeout(() => (saved = false), 2200);
  }
</script>

<div class="page">
  <h1 class="greeting">This week</h1>
  <p class="subtitle">A plain look at what you wrote. No model involved.</p>

  <div class="card mt-4">
    <div class="stats-grid">
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

    <p class="card-label mt-3">Words by day</p>
    <div class="chart">
      {#each stats.bars as day (day.label + day.date.toISOString())}
        <div class="chart-col">
          <div
            class="bar"
            class:zero={day.words === 0}
            style={`height:${6 + (day.words / maxWords) * 54}px`}
          ></div>
          <span class="bar-label">{day.label.substring(0, 1)}</span>
        </div>
      {/each}
    </div>
  </div>

  <div class="row mt-2">
    <span class="small">
      {stats.entries} {stats.entries === 1 ? 'entry' : 'entries'} in the last seven days
    </span>
    <div class="spacer"></div>
    <button class="btn" onclick={writeItUp} disabled={stats.entries === 0}>
      {saved ? 'Saved' : 'Write it up'}
    </button>
  </div>

  <div class="mt-4">
    {#if latest}
      <div class="letter-card">
        <p class="card-label">{periodLabel(latest.periodStart, latest.periodEnd)}</p>
        <p class="letter-text">{latest.content}</p>
      </div>
    {:else}
      <div class="empty-card">
        <div class="empty-icon"><PenLine size={20} /></div>
        <div>
          <p class="empty-title">Nothing written up yet.</p>
          <p class="empty-body">A few check-ins are enough. Write it up when you want.</p>
        </div>
      </div>
    {/if}
  </div>

  <div class="notice mt-3">
    <span class="notice-icon"><Sparkles size={17} /></span>
    <div>
      <p class="notice-title">Reflection is off</p>
      <p class="notice-body">
        When there is a model on your phone, this page gets a real letter. For
        now it is just a count.
      </p>
    </div>
  </div>
</div>
