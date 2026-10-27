<script lang="ts">
  import { BookOpen, PenLine, Settings, Sparkles } from 'lucide-svelte';
  import type { Tab } from '$lib/types';

  let {
    active,
    onChange
  }: {
    active: Tab;
    onChange: (tab: Tab) => void;
  } = $props();

  const items = [
    { id: 'today' as const, label: 'Today', icon: PenLine },
    { id: 'journal' as const, label: 'Journal', icon: BookOpen },
    { id: 'weekly' as const, label: 'Weekly', icon: Sparkles },
    { id: 'settings' as const, label: 'Settings', icon: Settings }
  ];
</script>

<nav class="bottom-nav" aria-label="Main">
  {#each items as item (item.id)}
    {@const Icon = item.icon}
    <button
      class="nav-item"
      class:active={active === item.id}
      onclick={() => onChange(item.id)}
      aria-label={item.label}
      aria-current={active === item.id ? 'page' : undefined}
    >
      <Icon size={20} strokeWidth={2} />
      <span>{item.label}</span>
    </button>
  {/each}
</nav>
