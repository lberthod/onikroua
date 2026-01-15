#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script pour transformer les mots italiens:
De: "limone (il)" → À: "il limone"
De: "madre (la)" → À: "la madre"
etc.
"""

import json
import re
import sys

def transform_word(word):
    """
    Transforme "mot (déterminant)" en "déterminant mot"
    Exemples:
    - "limone (il)" → "il limone"
    - "madre (la)" → "la madre"
    - "etichetta (l')" → "l'etichetta"
    """
    # Pattern pour capturer "mot (déterminant)"
    match = re.match(r'^(.+?)\s*\((il|la|lo|l\'|i|le|gli)\)$', word.strip())
    if match:
        mot = match.group(1).strip()
        determinant = match.group(2).strip()
        return f"{determinant} {mot}"
    return word

def main():
    file_path = 'onykroua/vocabulary_it.json'
    
    print("🔄 Lecture du fichier vocabulary_it.json...")
    
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
    except FileNotFoundError:
        print(f"❌ Fichier non trouvé: {file_path}")
        print("💡 Exécutez ce script depuis le dossier frontend-ios/")
        sys.exit(1)
    
    print("✅ Fichier chargé\n")
    
    # Parcourir toutes les catégories et transformer les mots
    count = 0
    examples = []
    
    for category in data:
        if 'words' in category:
            for word_entry in category['words']:
                if 'word' in word_entry:
                    original = word_entry['word']
                    transformed = transform_word(original)
                    
                    if original != transformed:
                        word_entry['word'] = transformed
                        count += 1
                        
                        # Garder les 10 premiers exemples
                        if len(examples) < 10:
                            examples.append((original, transformed))
    
    # Afficher quelques exemples
    print("📝 Exemples de transformations:")
    print("-" * 60)
    for orig, trans in examples:
        print(f"  '{orig}' → '{trans}'")
    print("-" * 60)
    print(f"\n✅ Total: {count} mots transformés\n")
    
    if count == 0:
        print("ℹ️  Aucune transformation nécessaire (déjà au bon format)")
        return
    
    # Sauvegarder le fichier
    print("💾 Sauvegarde du fichier...")
    with open(file_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    
    print("✅ Fichier vocabulary_it.json mis à jour avec succès!")
    print(f"✅ {count} mots ont été reformatés\n")

if __name__ == '__main__':
    main()
