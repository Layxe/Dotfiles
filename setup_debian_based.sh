sudo apt update && sudo apt -y upgrade

sudo apt-get install -y build-essential cmake git curl

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

# Install Neovim and Node.js
# ##################################################################################################

brew install neovim node

# Download neovim config

mkdir -p ~/.config
git clone https://github.com/Layxe/nvim ~/.config/nvim
