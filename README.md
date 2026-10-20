# Dotfiles

Managed with [chezmoi](https://chezmoi.io). Covers zsh/bash, neovim, oh-my-posh, zellij, alacritty, Claude Code (`~/.claude`) and pi (`~/.pi/agent`).

## New machine
```
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply Layxe
# debian-based bootstrap (brew, zsh, tools): see setup_debian_based.sh
```
Then create `~/.secrets.env` (chmod 600, never committed) with:
`LOGSEQ_PROXY_URL`, `LOGSEQ_PROXY_API_KEY`, `OLLAMA_API_KEY`, `VLLM_API_KEY`, `DEEPSEEK_API_KEY`.

## Daily use
```
chezmoi edit ~/.zshrc     # or edit the file, then: chezmoi add ~/.zshrc
chezmoi diff && chezmoi apply
chezmoi cd                # git add/commit/push here
chezmoi update            # pull + apply on another machine
```
