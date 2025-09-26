# Modèles Vosk pour MagicControl

Ce dossier doit contenir les modèles Vosk nécessaires pour la reconnaissance vocale offline.

## Modèles requis:

1. **Modèle français petit (vosk-model-small-fr-0.22.zip)**
   - URL de téléchargement: https://alphacephei.com/kaldi/models/vosk-model-small-fr-0.22.zip
   - Taille: ~40MB
   - Décompresser dans: `app/src/main/assets/models/vosk-model-small-fr/`

2. **Modèle anglais petit (vosk-model-small-en-us-0.15.zip)**
   - URL de téléchargement: https://alphacephei.com/kaldi/models/vosk-model-small-en-us-0.15.zip
   - Taille: ~39MB
   - Décompresser dans: `app/src/main/assets/models/vosk-model-small-en-us/`

## Instructions de téléchargement:

1. Télécharger manuellement les fichiers depuis les URLs ci-dessus
2. Décompresser chaque archive dans le dossier correspondant
3. Vérifier que les fichiers suivants sont présents:
   - `vosk-model-small-fr/am/final.mdl`
   - `vosk-model-small-fr/conf/mfcc.conf`
   - `vosk-model-small-fr/graph/`
   - `vosk-model-small-en-us/am/final.mdl`
   - `vosk-model-small-en-us/conf/mfcc.conf`
   - `vosk-model-small-en-us/graph/`

## Note:
Les modèles sont trop volumineux pour être inclus directement dans le repository.
Ils doivent être téléchargés et ajoutés manuellement lors du déploiement.