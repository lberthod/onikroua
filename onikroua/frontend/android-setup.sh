#!/bin/bash

# Script d'installation et configuration Android pour Onikroua
# Usage: ./android-setup.sh

set -e

echo "🚀 Configuration Android pour Onikroua"
echo "======================================"

# Vérifier Node.js
if ! command -v node &> /dev/null; then
    echo "❌ Node.js n'est pas installé"
    exit 1
fi

echo "✅ Node.js $(node -v) détecté"

# Vérifier npm
if ! command -v npm &> /dev/null; then
    echo "❌ npm n'est pas installé"
    exit 1
fi

echo "✅ npm $(npm -v) détecté"

# Installation des dépendances
echo ""
echo "📦 Installation des dépendances npm..."
npm install

# Build de l'application
echo ""
echo "🔨 Build de l'application web..."
npm run build

# Vérifier si le dossier android existe déjà
if [ -d "android" ]; then
    echo ""
    echo "⚠️  Le dossier android existe déjà"
    read -p "Voulez-vous le supprimer et recréer? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf android
    else
        echo "❌ Configuration annulée"
        exit 1
    fi
fi

# Ajouter la plateforme Android
echo ""
echo "📱 Ajout de la plateforme Android..."
npx cap add android

# Synchroniser
echo ""
echo "🔄 Synchronisation avec Android..."
npx cap sync android

echo ""
echo "✅ Configuration terminée!"
echo ""
echo "Prochaines étapes:"
echo "1. Ouvrir Android Studio: npm run android:open"
echo "2. Ou builder directement:"
echo "   - APK Debug: npm run android:build:debug"
echo "   - APK Release: npm run android:build"
echo "   - AAB Release: npm run android:bundle"
echo ""
echo "📖 Voir ANDROID_SETUP.md pour plus de détails"
