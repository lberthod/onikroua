#!/bin/bash
# Script pour créer le keystore de signature

echo "🔐 Création du keystore pour le Play Store"
echo ""
echo "Vous allez devoir entrer :"
echo "  - Un mot de passe pour le keystore (à retenir !)"
echo "  - Un mot de passe pour la clé (peut être le même)"
echo "  - Vos informations (nom, organisation, ville, etc.)"
echo ""

keytool -genkey -v -keystore app/onykroua-release.keystore \
  -alias onykroua-key \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000

echo ""
echo "✅ Keystore créé : app/onykroua-release.keystore"
echo "⚠️  IMPORTANT : Sauvegardez ce fichier et les mots de passe en lieu sûr !"
echo "   Sans eux, vous ne pourrez plus publier de mises à jour."
