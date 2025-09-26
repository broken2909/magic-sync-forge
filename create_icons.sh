#!/bin/bash
echo "🎨 Création des icônes placeholder..."

# Créer des fichiers PNG simples (1x1 pixel bleu) pour chaque densité
sizes=("mdpi:48" "hdpi:72" "xhdpi:96" "xxhdpi:144" "xxxhdpi:192")

for size in "${sizes[@]}"; do
    density=$(echo $size | cut -d: -f1)
    px=$(echo $size | cut -d: -f2)
    
    # Créer un fichier PNG simple (base64 d'un PNG 1x1 bleu)
    echo "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==" | base64 -d > app/src/main/res/mipmap-${density}/ic_launcher.png
    echo "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==" | base64 -d > app/src/main/res/mipmap-${density}/ic_launcher_round.png
    
    echo "✅ Icônes créées pour ${density} (${px}px)"
done

echo "🎉 Toutes les icônes ont été créées!"
