<script lang="ts">
  import { Pencil, Trash2 } from 'lucide-svelte';
  import { moodById } from '$lib/moods';
  import type { Entry } from '$lib/types';
  import { formatShortDate, formatTime } from '$lib/weekly';

  let {
    entry,
    onEdit,
    onDelete
  }: {
    entry: Entry;
    onEdit?: () => void;
    onDelete?: () => void;
  } = $props();

  const mood = $derived(moodById(entry.mood));
</script>

<article class="entry-card">
  <div class="entry-top">
    <div
      class="entry-avatar"
      style={`background:${mood?.soft ?? 'var(--paper-deep)'};color:${mood?.color ?? 'var(--faint)'}`}
      role="img"
      aria-label={mood?.label ?? 'Entry'}
    >
      {mood?.emoji ?? '📝'}
    </div>

    <div class="entry-main">
      <div class="entry-head">
        <span class="entry-date">
          {formatShortDate(entry.createdAt)} · {formatTime(entry.createdAt)}
        </span>
        <div class="spacer"></div>
        {#if onEdit || onDelete}
          <div class="entry-actions">
            {#if onEdit}
              <button class="icon-mini" onclick={onEdit} aria-label="Edit entry">
                <Pencil size={15} />
              </button>
            {/if}
            {#if onDelete}
              <button class="icon-mini" onclick={onDelete} aria-label="Delete entry">
                <Trash2 size={15} />
              </button>
            {/if}
          </div>
        {/if}
      </div>

      <p class="entry-content">{entry.content}</p>

      {#if entry.oneThing || entry.win}
        <div class="entry-tags">
          {#if entry.oneThing}
            <span class="tag">🎯 {entry.oneThing}</span>
          {/if}
          {#if entry.win}
            <span class="tag lime">✨ {entry.win}</span>
          {/if}
        </div>
      {/if}
    </div>
  </div>
</article>
