<div align="center">

# स्मृति · Smriti

### A local-first journal that remembers.

**Bring your own model. Your words never leave your machine.**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
![Status](https://img.shields.io/badge/status-early%20development-orange)
![Local-first](https://img.shields.io/badge/local--first-yes-brightgreen)
![Bring your own model](https://img.shields.io/badge/model-bring%20your%20own-blue)

</div>

---

Smriti is a quiet, private journal for people whose brains run on their own schedule. A short check-in becomes a searchable memory, and once a week it writes you a reflection that connects the dots — without sending your life to someone else's server.

Built solo by someone with ADHD. Not medical care. Just the thing that helped me.

> **Status: early development.** This repository is the public home of Smriti. The first build is coming. Star or watch the repo to follow along.

---

## The loop

1. **Check in.** Write a few lines about how the day actually went.
2. **It remembers.** Smriti pulls out the people, themes, moods, goals, wins, and blockers.
3. **It reflects.** Once a week, you get a short letter: patterns, contradictions, and one small experiment for next week.
4. **You can ask.** "When did I last feel excited about work?" — answered with dates and quotes from your own entries.

No streaks. No shame. No engagement traps.

---

## What v0.1 will include

| Feature | Status |
|---|---|
| Daily text check-in | Planned |
| Timeline of entries | Planned |
| Memory extraction | Planned |
| Weekly reflection letter | Planned |
| Ask-your-journal with citations | Planned |
| Export / import | Planned |
| Bring-your-own-model settings | Planned |
| Local SQLite storage | Planned |
| No account, no telemetry, no Smriti server | By design |

Voice, desktop packaging, mobile, encrypted sync, and deeper memory come later.

---

## Bring your own model

Smriti speaks the OpenAI-compatible API, so it works with what you already run:

- **Ollama** — `http://localhost:11434/v1`
- **llama.cpp** — `http://localhost:8080/v1`
- **LM Studio** — `http://localhost:1234/v1`
- **OpenRouter / OpenAI** — cloud, with a clear warning

Local by default. No model weights are shipped with this repo. You choose the model, the endpoint, and the key.

---

## Privacy

There is no Smriti server.

- Your journal is a local SQLite file on your machine.
- No account. No analytics by default. No data sale.
- If you use a local model, nothing leaves your machine.
- If you configure a cloud model, that provider sees your prompts. The app will tell you this plainly.

The promise is not "we won't look." It is "there is nowhere for us to look."

---

## Safety

Smriti is **not** a crisis service and **not** medical care. If you are in immediate danger, contact your local emergency number.

The app can show local support resources and a non-blocking safety notice when it detects language that may need care. It cannot monitor you centrally — because it cannot read your data. That is the trade, and it is stated honestly.

---

## Principles

- **Useful first.** The daily habit should work before any advanced feature.
- **Private by architecture.** Local storage, local model option, no central plaintext.
- **Bring your own model.** No vendor lock-in, no hidden inference bill.
- **No shame mechanics.** No streaks, no guilt, no dark patterns.
- **Open source.** MIT, forkable, inspectable.

---

## Roadmap

- **v0.1** — text check-in, timeline, basic memory, weekly letter, ask, export/import, BYO model.
- **v0.2** — better retrieval, voice check-ins, desktop build.
- **v0.3** — encrypted sync and mobile capture, still local-first.

The roadmap is a direction, not a promise. The repo will move at the speed of what is actually useful.

---

## Contributing

Feedback, ideas, safety review, and bug reports are welcome. Open an issue or start a discussion.

If you work in mental health, safety, or privacy, your review matters more than a pull request. Please get in touch.

---

## License

MIT. See [LICENSE](LICENSE).

---

## Credits

Built solo by [T4tsuk3i](https://github.com/T4tsuk3i). AI tools were used to assist with development.

---

<div align="center">

**If you have ever wanted a journal that remembers without selling you out, star the repo.**

That is the signal that this should exist.

</div>
