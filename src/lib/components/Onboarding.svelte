<script lang="ts">
  import { Check, Heart, Lock } from 'lucide-svelte';
  import { setSetting } from '$lib/state.svelte';

  let { onDone }: { onDone: () => void } = $props();

  let name = $state('');

  function start() {
    setSetting('userName', name.trim());
    setSetting('onboarded', true);
    onDone();
  }
</script>

<div class="onboarding">
  <div class="onboarding-inner">
    <div class="wordmark">
      <span class="deva">स्मृति</span>
      <span class="latin">Smriti</span>
      <span class="dot"></span>
    </div>

    <h1>A place<br />for the day.</h1>
    <p class="onboarding-copy">
      Write a line. Pick a mood. Close it. No performance, no audience, no
      streak to break.
    </p>

    <ul class="onboarding-list">
      <li>
        <span class="tick"><Lock size={12} /></span>
        <span>It stays on this phone. No account, no server, no analytics.</span>
      </li>
      <li>
        <span class="tick"><Heart size={12} /></span>
        <span>Start with one line. The two-minute version counts.</span>
      </li>
      <li>
        <span class="tick"><Check size={12} /></span>
        <span>No model is included. Writing works without one.</span>
      </li>
    </ul>

    <input
      class="field mt-3"
      bind:value={name}
      maxlength="40"
      placeholder="What should it call you? (optional)"
      aria-label="Your name"
    />

    <p class="fine">
      Smriti is not a crisis service or medical care. If you are in immediate
      danger, contact your local emergency number.
    </p>

    <button class="btn big" onclick={start}>Start</button>
  </div>
</div>
