# Génération des icônes pour Android/PWA

## Méthode 1: Utilisation d'un outil en ligne

1. Créer une icône source (au moins 512x512px)
2. Utiliser [PWA Asset Generator](https://www.pwabuilder.com/imageGenerator)
3. Télécharger les icônes générées
4. Placer dans le dossier `public/`:
   - `pwa-192x192.png`
   - `pwa-512x512.png`
   - `apple-touch-icon.png` (180x180)

## Méthode 2: Avec ImageMagick (si installé)

```bash
# Installer ImageMagick si nécessaire
# brew install imagemagick (macOS)

# Partir d'une icône source (icon.png 1024x1024 ou plus)
convert icon.png -resize 192x192 public/pwa-192x192.png
convert icon.png -resize 512x512 public/pwa-512x512.png
convert icon.png -resize 180x180 public/apple-touch-icon.png
```

## Méthode 3: Automatique avec Capacitor Assets

Après avoir créé une icône `icon.png` (1024x1024) dans le dossier racine:

```bash
npm install -g @capacitor/assets
npx @capacitor/assets generate --android --ios
```

Cela générera automatiquement toutes les tailles d'icônes nécessaires.

## Icônes recommandées

- **icon.png** (1024x1024) - Icône source
- **pwa-192x192.png** - Icône PWA small
- **pwa-512x512.png** - Icône PWA large
- **apple-touch-icon.png** (180x180) - Pour iOS
- **favicon.svg** - Favicon moderne

## Splash Screen Android

Pour personnaliser le splash screen Android, après avoir ajouté la plateforme:

1. Placer `splash.png` (2732x2732) dans `android/app/src/main/res/drawable/`
2. Ou utiliser Android Image Asset Studio dans Android Studio

## Notes

- Les icônes doivent être au format PNG
- Fond transparent ou couleur unie selon votre design
- Éviter du texte trop petit (illisible sur petites tailles)
- Tester sur différents backgrounds (clair/foncé)
