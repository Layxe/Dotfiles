sudo apt update && sudo apt -y upgrade

sudo apt-get install -y build-essential cmake git curl zsh

# Install Homebrew
# ##################################################################################################

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Dotfiles via chezmoi (zsh, bash, nvim, oh-my-posh, zellij, alacritty, claude, pi).
# Applying them also installs the packages from ~/.Brewfile (fzf, ripgrep, bat, neovim, node, ...).
# ##################################################################################################

# Create ~/.secrets.env first (see README)
brew install chezmoi
chezmoi init --apply Layxe

echo "Setup finished"
