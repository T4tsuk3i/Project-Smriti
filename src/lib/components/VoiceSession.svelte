<script lang="ts">
  import { onDestroy } from 'svelte';
  import { Check, Mic, Sparkles, Square, X } from 'lucide-svelte';
  import { inTauri } from '$lib/model.svelte';
  import { scheduleOneOff } from '$lib/reminders.svelte';
  import { checkSafety } from '$lib/safety';
  import { addEntry, app } from '$lib/state.svelte';
  import { cancelListening, speechState, startListening, stopListening } from '$lib/speech.svelte';
  import type { MoodId, SafetyCheck, VoiceIntent } from '$lib/types';

  let {
    intent,
    onClose
  }: {
    intent: VoiceIntent;
    onClose: () => void;
  } = $props();

  const OPENERS: Record<VoiceIntent, string> = {
    talk: "What's on your mind right now?",
    stuck: 'What are you avoiding?',
    remember: 'What do you need to remember?',
    winddown: "What's still in your head?"
  };

  const LABELS: Record<VoiceIntent, string> = {
    talk: 'Voice check-in',
    stuck: 'Get unstuck',
    remember: 'Remember this',
    winddown: 'Wind down'
  };

  // svelte-ignore state_referenced_locally
  let current = $state(OPENERS[intent]);
  // svelte-ignore state_referenced_locally
  let questions = $state<string[]>([OPENERS[intent]]);
  let answers = $state<string[]>([]);
  let step = $state(0);
  let typed = $state('');
  let error = $state('');
  let finished = $state(false);
  let summary = $state('');
  let reminderText = $state('');
  let safety = $state<SafetyCheck | null>(null);
  let saved = $state(false);

  const CHIPS: Record<string, string[]> = {
    'What are you avoiding?': ['A task', 'A message', 'A feeling', "I don't know"],
    'What makes it hard?': ['Too big', 'Unclear', 'Boring', 'Tired', 'Afraid'],
    "What's the smallest version?": ['Open it', 'One line', 'Two minutes', 'Ask for help'],
    'When should I bring it back?': ['Tonight', 'Tomorrow morning', 'This week'],
    'What can wait until tomorrow?': ['Everything', 'The list', 'A message', 'Nothing'],
    "What's one thing for tomorrow?": ['Rest', 'One small task', 'Ask for help', 'Nothing'],
    "What's on your mind right now?": ['Work', 'People', 'My body', 'Money', 'Nothing'],
    'What would make it 10% easier?': ['Water', 'A walk', 'A shower', 'Lower the bar'],
    "What's one thing you want to remember about this?": ['A win', 'A feeling', 'Something I said', 'Nothing']
  };

  const chips = $derived(CHIPS[current] ?? []);
  const pulse = $derived(1 + Math.min(0.12, Math.max(0, (speechState.level + 2) / 100)));

  onDestroy(() => {
    void cancelListening();
  });

  function followUp(text: string): string {
    const value = text.toLowerCase();
    if (/(avoid|stuck|can't|cant|procrast|don't want|dont want)/.test(value)) {
      return 'What makes it hard to start?';
    }
    if (/(tired|exhaust|sleep|drained|rest)/.test(value)) {
      return 'What would make tonight 10% easier?';
    }
    if (/(work|job|office|deadline|invoice|email)/.test(value)) {
      return 'What part of work is taking the most space?';
    }
    if (/(friend|family|partner|people|message|call)/.test(value)) {
      return 'Who is taking up space?';
    }
    if (/(good|happy|great|proud|worked)/.test(value)) {
      return 'What made today work?';
    }
    return 'What is the part you keep coming back to?';
  }

  function inferMood(text: string): MoodId | undefined {
    const value = text.toLowerCase();
    if (/(heavy|awful|terrible|hate|angry|furious)/.test(value)) return 'heavy';
    if (/(sad|low|down|tired|drained|anxious|worried)/.test(value)) return 'low';
    if (/(good|happy|great|proud|excited)/.test(value)) return 'good';
    if (/(okay|fine|alright)/.test(value)) return 'okay';
    if (/(numb|nothing)/.test(value)) return 'numb';
    return undefined;
  }

  function nextQuestion(question: string) {
    questions = [...questions, question];
    current = question;
    typed = '';
  }

  async function handleAnswer(value: string) {
    const clean = value.trim();
    if (!clean) return;

    answers = [...answers, clean];
    error = '';

    if (intent === 'remember') {
      if (step === 0) {
        step = 1;
        nextQuestion('When should I bring it back?');
        return;
      }
      if (step === 1) {
        const when = rememberAt(clean);
        const ok = await scheduleOneOff('Smriti', answers[0] ?? 'Remember this', when);
        if (ok) {
          reminderText = `Reminder set for ${when.toLocaleString(undefined, {
            weekday: 'short',
            hour: 'numeric',
            minute: '2-digit'
          })}.`;
        }
        finish();
        return;
      }
    }

    if (intent === 'stuck') {
      if (step === 0) {
        step = 1;
        nextQuestion('What makes it hard?');
        return;
      }
      if (step === 1) {
        step = 2;
        nextQuestion("What's the smallest version?");
        return;
      }
      finish();
      return;
    }

    if (intent === 'winddown') {
      if (step === 0) {
        step = 1;
        nextQuestion('What can wait until tomorrow?');
        return;
      }
      if (step === 1) {
        step = 2;
        nextQuestion("What's one thing for tomorrow?");
        return;
      }
      finish();
      return;
    }

    if (step === 0) {
      step = 1;
      nextQuestion(followUp(clean));
      return;
    }
    if (step === 1) {
      step = 2;
      nextQuestion('What would make it 10% easier?');
      return;
    }
    if (step === 2) {
      step = 3;
      nextQuestion("What's one thing you want to remember about this?");
      return;
    }
    finish();
  }

  function finish() {
    const body = questions
      .map((question, index) => `${question}\n${answers[index] ?? ''}`)
      .join('\n\n');
    summary = `${LABELS[intent]}\n\n${body}${reminderText ? `\n\n${reminderText}` : ''}`;
    safety = checkSafety(answers.join(' '), app.settings.country);
    finished = true;
  }

  function rememberAt(value: string): Date {
    const now = new Date();
    const lower = value.toLowerCase();
    const date = new Date(now);

    if (lower.includes('tonight')) {
      date.setHours(20, 0, 0, 0);
      if (date <= now) date.setDate(date.getDate() + 1);
      return date;
    }
    if (lower.includes('tomorrow')) {
      date.setDate(date.getDate() + 1);
      date.setHours(9, 0, 0, 0);
      return date;
    }
    if (lower.includes('week')) {
      date.setDate(date.getDate() + 3);
      date.setHours(9, 0, 0, 0);
      return date;
    }
    date.setDate(date.getDate() + 1);
    date.setHours(9, 0, 0, 0);
    return date;
  }

  async function listen() {
    if (speechState.listening) {
      await stopListening();
      return;
    }

    error = '';
    try {
      const text = await startListening();
      await handleAnswer(text);
    } catch (err) {
      error = err instanceof Error ? err.message : String(err);
    }
  }

  function submitTyped(event: Event) {
    event.preventDefault();
    void handleAnswer(typed);
  }

  function save() {
    if (saved) return;
    addEntry({
      content: summary,
      mood: inferMood(answers.join(' ')),
      oneThing: intent === 'stuck' ? answers[2] : undefined
    });
    saved = true;
    setTimeout(onClose, 900);
  }

  async function close() {
    await cancelListening();
    onClose();
  }
</script>

<div class="voice-screen">
  <div class="voice-inner">
    <div class="voice-top">
      <button class="icon-btn" onclick={close} aria-label="Close voice check-in">
        <X size={20} />
      </button>
      <div class="voice-progress" aria-hidden="true">
        {#each Array(4) as _, index}
          <span class="voice-dot" class:active={index <= step}></span>
        {/each}
      </div>
      <span class="voice-label">{LABELS[intent]}</span>
    </div>

    {#if !finished}
      <div class="voice-body">
        <p class="voice-eyebrow">
          {inTauri() ? 'Talk or type. One question at a time.' : 'Type below. Voice is in the Android app.'}
        </p>
        <h1 class="voice-question">{current}</h1>

        <button
          class="voice-orb"
          class:listening={speechState.listening}
          style={`--pulse:${pulse}`}
          onclick={listen}
          aria-label={speechState.listening ? 'Stop listening' : 'Answer by voice'}
        >
          {#if speechState.listening}
            <Square size={24} fill="currentColor" />
          {:else}
            <Mic size={34} />
          {/if}
        </button>

        <p class="voice-hint">
          {speechState.listening ? 'Listening… tap to stop' : 'Tap and talk'}
        </p>

        {#if speechState.partial}
          <p class="voice-transcript">{speechState.partial}</p>
        {/if}

        {#if error}
          <p class="voice-error">{error}</p>
        {/if}

        {#if chips.length > 0}
          <div class="voice-chips">
            {#each chips as chip (chip)}
              <button class="chip" onclick={() => handleAnswer(chip)}>{chip}</button>
            {/each}
          </div>
        {/if}

        <form class="voice-type" onsubmit={submitTyped}>
          <input bind:value={typed} placeholder="Or type your answer" aria-label="Type your answer" />
          <button class="btn" type="submit" disabled={!typed.trim()}>Send</button>
        </form>

        <button class="voice-skip" onclick={close}>Stop here</button>
      </div>
    {:else}
      <div class="voice-body voice-finished">
        <div class="voice-finished-icon"><Sparkles size={24} /></div>
        <h1 class="voice-question">Here's what I heard.</h1>
        <div class="voice-summary">
          {#each questions as question, index}
            <div class="voice-answer">
              <p class="voice-answer-q">{question}</p>
              <p class="voice-answer-a">{answers[index] ?? ''}</p>
            </div>
          {/each}
          {#if reminderText}
            <p class="voice-reminder">{reminderText}</p>
          {/if}
        </div>

        {#if safety?.flagged}
          <div class="safety">
            <p class="safety-title">That sounds heavy.</p>
            <p>
              If you might be in danger, please contact a local helpline or
              emergency services. Smriti cannot monitor you.</p>
            <ul>
              {#each safety.resources as resource (resource.label)}
                <li>{resource.label} — {resource.contact}</li>
              {/each}
            </ul>
          </div>
        {/if}

        <button class="btn big" onclick={save}>
          <Check size={17} /> {saved ? 'Saved. That counts.' : 'Save to journal'}
        </button>
        <button class="btn ghost big" onclick={close}>Done</button>
      </div>
    {/if}
  </div>
</div>
