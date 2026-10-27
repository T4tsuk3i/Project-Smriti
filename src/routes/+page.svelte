<script lang="ts">
  import { onMount } from 'svelte';
  import { Lock, Timer } from 'lucide-svelte';
  import FocusTimer from '$lib/components/FocusTimer.svelte';
  import Journal from '$lib/components/Journal.svelte';
  import Nav from '$lib/components/Nav.svelte';
  import Onboarding from '$lib/components/Onboarding.svelte';
  import Settings from '$lib/components/Settings.svelte';
  import StuckSheet from '$lib/components/StuckSheet.svelte';
  import Today from '$lib/components/Today.svelte';
  import Weekly from '$lib/components/Weekly.svelte';
  import { app } from '$lib/state.svelte';
  import { refreshModel } from '$lib/model.svelte';
  import type { Tab } from '$lib/types';

  let tab = $state<Tab>('today');
  let showStuck = $state(false);
  let showFocus = $state(false);
  let showOnboarding = $state(!app.settings.onboarded);
  let mainEl = $state<HTMLElement | null>(null);

  onMount(() => {
    void refreshModel();
  });

  function go(next: Tab) {
    tab = next;
    if (mainEl) mainEl.scrollTop = 0;
  }
</script>

<div class="app">
  <header class="app-header">
    <div class="wordmark">
      <span class="deva">स्मृति</span>
      <span class="latin">Smriti</span>
      <span class="dot"></span>
    </div>
    <div class="header-actions">
      <button class="icon-btn" onclick={() => (showFocus = true)} aria-label="Focus timer">
        <Timer size={19} />
      </button>
      <span class="lock" title="Stored on this phone"><Lock size={16} /></span>
    </div>
  </header>

  <main class="app-main" bind:this={mainEl}>
    {#if tab === 'today'}
      <Today
        onOpenJournal={() => go('journal')}
        onOpenSettings={() => go('settings')}
        onStuck={() => (showStuck = true)}
        onFocus={() => (showFocus = true)}
      />
    {:else if tab === 'journal'}
      <Journal />
    {:else if tab === 'weekly'}
      <Weekly />
    {:else}
      <Settings />
    {/if}
  </main>

  <Nav active={tab} onChange={go} />
</div>

{#if showStuck}
  <StuckSheet onClose={() => (showStuck = false)} />
{/if}

{#if showFocus}
  <FocusTimer onClose={() => (showFocus = false)} />
{/if}

{#if showOnboarding}
  <Onboarding onDone={() => (showOnboarding = false)} />
{/if}
