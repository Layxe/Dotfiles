sudo apt update && sudo apt -y upgrade

sudo apt-get install -y build-essential cmake git curl zsh

# Install Homebrew
# ##################################################################################################

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

echo >> ~/.bashrc
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.bashrc

source ~/.bashrc

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Install fzf, ripgrep, bat, needed for nice experience in terminal
# ##################################################################################################

brew install fzf ripgrep bat

# Setup fzf config in the bashrc
echo >> ~/.bashrc

echo 'eval "$(fzf --bash)"' >> ~/.bashrc

echo "export FZF_DEFAULT_OPTS='--preview \"bat --style=numbers --color=always --line-range :500 {}\"'" >> ~/.bashrc

echo >> ~/.bashrc

# Disable file preview when browsing folders
echo "_fzf_comprun() {"                                                    >> ~/.bashrc
echo "  local command=\$1"                                                 >> ~/.bashrc
echo "  shift"                                                             >> ~/.bashrc
echo "  case \"\$command\" in"                                             >> ~/.bashrc
echo "    cd)           fzf \"\$@\" --preview 'tree -C {} | head -200' ;;" >> ~/.bashrc
echo "    *)            fzf \"\$@\" ;;"                                    >> ~/.bashrc
echo "  esac"                                                              >> ~/.bashrc
echo "}"                                                                   >> ~/.bashrc

echo "alias vim=nvim" >> ~/.bashrc

# Install Neovim and Node.js
# ##################################################################################################

brew install neovim node

# Install tree-sitter for latex
npm install -g tree-sitter-cli


# Dotfiles (zsh, bash, nvim, oh-my-posh, zellij, alacritty, claude, pi) via chezmoi
# ##################################################################################################

brew install chezmoi
chezmoi init --apply Layxe

echo "Create ~/.secrets.env (see README) for API keys"
echo "Setup finished"
