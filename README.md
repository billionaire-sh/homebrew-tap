# billionaire — Homebrew tap

Homebrew tap for the [billionaire CLI](https://github.com/billionaire-sh/cli).

```sh
brew tap billionaire-sh/tap
brew install billionaire
billionaire --version
```

To upgrade later: `brew upgrade billionaire`.

---

## What lives here

This repository hosts only the Homebrew formula. It is published from
the kadal monorepo (`apps/billionaire/cli/homebrew/billionaire.rb` template)
on every CLI release. The actual binaries are attached to GitHub
Releases on [`billionaire-sh/cli`](https://github.com/billionaire-sh/cli/releases).

Hand edits to `Formula/billionaire.rb` are overwritten on the next
release; treat this repository as a publishing target, not a working
tree.

## Issues / PRs

Issues for the CLI itself: <https://github.com/billionaire-sh/cli/issues>.
