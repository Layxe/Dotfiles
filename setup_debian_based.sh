# Install Homebrew
# ##################################################################################################

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

echo >> ~/.bashrc
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.bashrc

source ~/.bashrc

# Install fzf, ripgrep, bat, needed for nice experience in terminal
# ##################################################################################################

brew install fzf ripgrep bat

echo >> ~/.bashrc

eval "$(fzf --bash)"

# Setup fzf
# TODO

# Install Neovim and Node.js
# ##################################################################################################

brew install neovim node

# Download neovim config

mkdir -p ~/.config
git clone https://github.com/Layxe/nvim ~/.config/nvim
