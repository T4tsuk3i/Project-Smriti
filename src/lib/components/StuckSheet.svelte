<script lang="ts">
  import { ArrowRight, CircleHelp } from 'lucide-svelte';

  let { onClose }: { onClose: () => void } = $props();

  const options = [
    {
      id: 'big',
      label: 'Too big',
      step: 'Pick the smallest visible part. The version that takes two minutes. Do only that.'
    },
    {
      id: 'unclear',
      label: 'Unclear',
      step: 'Write the next physical action, not the whole task. “Open the file” counts.'
    },
    {
      id: 'boring',
      label: 'Boring',
      step: 'Pair it with something you like for ten minutes. Music, a drink, a body double.'
    },
    {
      id: 'tired',
      label: 'Tired',
      step: 'Do the lying-down version, or skip it without turning it into a story about you.'
    },
    {
      id: 'afraid',
      label: 'Afraid',
      step: 'Write the worst realistic outcome. Then one thing you can still do anyway.'
    }
  ];

  let chosen = $state<(typeof options)[number] | null>(null);
</script>

<svelte:window onkeydown={(event) => event.key === 'Escape' && onClose()} />

<div class="sheet-backdrop" role="presentation" onclick={onClose}>
  <div
    class="sheet"
    role="dialog"
    tabindex="-1"
    aria-modal="true"
    aria-label="Stuck"
    onclick={(event) => event.stopPropagation()}
    onkeydown={(event) => event.stopPropagation()}
  >
    <div class="sheet-handle"></div>
    <div class="row">
      <div class="settings-icon" style="--icon-color: var(--rust)"><CircleHelp size={19} /></div>
      <div>
        <h2 class="sheet-title">Stuck?</h2>
        <p class="sheet-body">Pick the closest one. We’ll shrink it.</p>
      </div>
    </div>

    <div class="option-list">
      {#each options as option (option.id)}
        <button
          class="option"
          class:selected={chosen?.id === option.id}
          onclick={() => (chosen = option)}
        >
          {option.label}
        </button>
      {/each}
    </div>

    {#if chosen}
      <div class="next-step">
        <strong>Try this:</strong> {chosen.step}
      </div>
      <button class="btn big mt-3" onclick={onClose}>
        Okay <ArrowRight size={15} />
      </button>
    {:else}
      <button class="btn ghost big mt-3" onclick={onClose}>Not now</button>
    {/if}
  </div>
</div>
