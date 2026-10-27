<script lang="ts">
  import { onDestroy } from 'svelte';
  import { Pause, Play, RotateCcw, Timer } from 'lucide-svelte';

  let { onClose }: { onClose: () => void } = $props();

  let minutes = $state(10);
  let remaining = $state(10 * 60);
  let running = $state(false);
  let finished = $state(false);
  let interval: ReturnType<typeof setInterval> | null = null;

  function clearTimer() {
    if (interval) {
      clearInterval(interval);
      interval = null;
    }
  }

  function tick() {
    if (remaining > 0) {
      remaining -= 1;
      return;
    }
    clearTimer();
    running = false;
    finished = true;
  }

  function toggle() {
    if (finished) reset(minutes);
    if (running) {
      clearTimer();
      running = false;
      return;
    }
    running = true;
    interval = setInterval(tick, 1000);
  }

  function reset(value = minutes) {
    clearTimer();
    running = false;
    finished = false;
    remaining = value * 60;
  }

  function choose(value: number) {
    minutes = value;
    reset(value);
  }

  function display(): string {
    const mins = Math.floor(remaining / 60);
    const secs = remaining % 60;
    return `${String(mins).padStart(2, '0')}:${String(secs).padStart(2, '0')}`;
  }

  onDestroy(clearTimer);
</script>

<svelte:window onkeydown={(event) => event.key === 'Escape' && onClose()} />

<div class="sheet-backdrop" role="presentation" onclick={onClose}>
  <div
    class="sheet"
    role="dialog"
    tabindex="-1"
    aria-modal="true"
    aria-label="Focus timer"
    onclick={(event) => event.stopPropagation()}
    onkeydown={(event) => event.stopPropagation()}
  >
    <div class="sheet-handle"></div>
    <div class="row">
      <div class="settings-icon" style="--icon-color: var(--sage)"><Timer size={19} /></div>
      <div>
        <h2 class="sheet-title">Focus</h2>
        <p class="sheet-body">One small block. No streak, no score.</p>
      </div>
    </div>

    <div class="timer-box">
      <div class="row">
        <button class="btn soft" class:selected={minutes === 10} onclick={() => choose(10)}>10 min</button>
        <button class="btn soft" onclick={() => choose(25)}>25 min</button>
      </div>
      <p class="timer-value">{display()}</p>
      {#if finished}
        <p class="timer-hint">Done. That counts.</p>
      {:else if running}
        <p class="timer-hint">Stay with the small thing. You can stop after this.</p>
      {:else}
        <p class="timer-hint">Start where you are. Two minutes is allowed.</p>
      {/if}
      <div class="row">
        <button class="btn" onclick={toggle}>
          {#if running}
            <Pause size={16} /> Pause
          {:else}
            <Play size={16} /> {finished ? 'Again' : 'Start'}
          {/if}
        </button>
        <button class="btn ghost" onclick={() => reset()}>
          <RotateCcw size={15} /> Reset
        </button>
      </div>
    </div>

    <button class="btn ghost big" onclick={onClose}>Close</button>
  </div>
</div>
