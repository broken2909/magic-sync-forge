# Bibliothèques natives pour MagicControl

Ce dossier doit contenir les bibliothèques natives nécessaires.

## Vosk Android Library

La bibliothèque Vosk Android est requise pour la reconnaissance vocale offline.

### Téléchargement requis:

**vosk-android-0.3.32.aar**
- URL: https://repo1.maven.org/maven2/com/alphacephei/vosk-android/0.3.32/vosk-android-0.3.32.aar
- Taille: ~12MB
- Placer dans: `app/libs/vosk-android.aar`

### Instructions:

1. Télécharger le fichier .aar depuis l'URL Maven
2. Placer le fichier dans ce dossier avec le nom exact: `vosk-android.aar`
3. Le fichier sera automatiquement lié via la configuration Gradle

### Note:
Le fichier est trop volumineux pour être inclus dans le repository.
Il doit être téléchargé manuellement lors du déploiement.