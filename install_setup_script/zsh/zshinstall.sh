#!/bin/bash

echo "🔍 Checking for Zsh..."
if ! command -v zsh &> /dev/null; then
    echo "📥 Installing Zsh..."
    sudo apt update && sudo apt install -y zsh
else
    echo "✅ Zsh is already installed!"
fi

echo "🔍 Checking default shell..."
if [[ "$SHELL" != "$(which zsh)" ]]; then
    echo "🔄 Changing default shell to Zsh..."
    chsh -s $(which zsh)
    echo "ℹ️ Please log out and log back in for the shell change to take effect."
else
    echo "✅ Zsh is already the default shell!"
fi

echo "🔍 Checking for Oh My Zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "📥 Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
    echo "✅ Oh My Zsh is already installed!"
fi

# Define Zsh custom plugins path
ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}

# Install plugins if not present
echo "🔍 Checking for plugins..."
PLUGINS=("zsh-autosuggestions" "zsh-syntax-highlighting")

for plugin in "${PLUGINS[@]}"; do
    if [ ! -d "$ZSH_CUSTOM/plugins/$plugin" ]; then
        echo "📥 Installing $plugin..."
        git clone "https://github.com/zsh-users/$plugin" "$ZSH_CUSTOM/plugins/$plugin"
    else
        echo "✅ $plugin is already installed!"
    fi
done

# Update .zshrc configurations
ZSHRC="$HOME/.zshrc"

# Ensure completion scripts are sourced
echo "🔍 Checking and adding completion scripts..."
grep -qxF 'source <(kubectl completion zsh)' "$ZSHRC" || echo 'source <(kubectl completion zsh)' >> "$ZSHRC"
grep -qxF 'source <(helm completion zsh)' "$ZSHRC" || echo 'source <(helm completion zsh)' >> "$ZSHRC"

# Ensure alias for kubecolor is set
echo "🔍 Checking and adding alias for kubectl..."
grep -qxF 'alias kubectl=kubecolor' "$ZSHRC" || echo 'alias kubectl=kubecolor' >> "$ZSHRC"
grep -qxF 'compdef kubecolor=kubectl' "$ZSHRC" || echo 'compdef kubecolor=kubectl' >> "$ZSHRC"

# Update theme if not already set
echo "🎨 Setting theme to 'fino'..."
sed -i 's/^ZSH_THEME=".*"/ZSH_THEME="fino"/g' "$ZSHRC"

# Ensure plugins are added in .zshrc
echo "🔧 Updating plugins in .zshrc..."
if ! grep -q 'plugins=(git zsh-autosuggestions zsh-syntax-highlighting kubectl)' "$ZSHRC"; then
    sed -i 's/^plugins=(.*)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting kubectl)/g' "$ZSHRC"
fi

# Apply changes
echo "🔄 Reloading Zsh configuration..."
exec zsh

echo "🎉 Setup complete! Restart your terminal or log out and log back in for full effect 🚀"
