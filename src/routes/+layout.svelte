<script lang="ts">
  import '../app.css';
  import type { LayoutProps } from './$types';

  let { children }: LayoutProps = $props();
</script>

<svelte:head>
  <title>Smriti</title>
  <meta
    name="description"
    content="A local-first journal that remembers. Android-first, Tauri + Svelte + Rust."
  />
  <meta name="theme-color" content="#FBF3E8" />
</svelte:head>

{@render children()}
