#!/bin/bash

echo "🔧 Installation de Ruby 3.3 pour fastlane..."

# Installer rbenv si pas déjà fait
if ! command -v rbenv &> /dev/null; then
    echo "📦 Installation de rbenv..."
    brew install rbenv ruby-build
fi

# Installer Ruby 3.3
echo "📦 Installation de Ruby 3.3.0..."
rbenv install 3.3.0

# Définir Ruby 3.3 comme version locale pour ce projet
echo "✅ Configuration de Ruby 3.3.0 pour ce projet..."
rbenv local 3.3.0

# Ajouter rbenv au PATH dans .zshrc si pas déjà fait
if ! grep -q 'rbenv init' ~/.zshrc; then
    echo "" >> ~/.zshrc
    echo "# rbenv configuration" >> ~/.zshrc
    echo 'eval "$(rbenv init - zsh)"' >> ~/.zshrc
    echo "✅ rbenv ajouté à ~/.zshrc"
fi

# Sourcer pour la session actuelle
eval "$(rbenv init - zsh)"

echo ""
echo "✅ Ruby 3.3.0 installé!"
echo "🔄 Redémarrez votre terminal ou lancez:"
echo "   eval \"\$(rbenv init - zsh)\""
echo ""
echo "Puis lancez:"
echo "   bundle install"
