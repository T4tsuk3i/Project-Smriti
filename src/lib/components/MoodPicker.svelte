<script lang="ts">
  import { MOODS } from '$lib/moods';
  import type { MoodId } from '$lib/types';

  let {
    value,
    onChange
  }: {
    value?: MoodId;
    onChange: (mood: MoodId | undefined) => void;
  } = $props();
</script>

<div class="mood-row" role="group" aria-label="How are you arriving?">
  {#each MOODS as mood, index (mood.id)}
    <button
      type="button"
      class="mood-button"
      class:selected={value === mood.id}
      style={`--mood-color:${mood.color};--mood-soft:${mood.soft};--face-delay:${index * 0.16}s`}
      aria-pressed={value === mood.id}
      onclick={() => onChange(value === mood.id ? undefined : mood.id)}
    >
      <span class="emoji" aria-hidden="true">{mood.emoji}</span>
      <span class="label">{mood.label}</span>
    </button>
  {/each}
</div>
