#!/bin/bash

# =============================================================================
# SCRIPT DE CORRECTION COMPLÈTE DU BUILD MAGICCONTROL
# Exécution: cd /data/data/com.termux/files/home/no-see-clean && bash fix_magiccontrol_build.sh
# =============================================================================

echo "🚀 Démarrage de la correction du build MagicControl..."

# =============================================================================
# ÉTAPE 1: Vérification du répertoire et sauvegarde
# =============================================================================
echo ""
echo "📁 ÉTAPE 1: Vérification du répertoire et sauvegarde..."

PROJECT_DIR="/data/data/com.termux/files/home/no-see-clean"

if [ ! -d "$PROJECT_DIR" ]; then
    echo "❌ Erreur: Le répertoire du projet n'existe pas: $PROJECT_DIR"
    exit 1
fi

cd "$PROJECT_DIR"

# Sauvegarde du build.gradle original si existant
if [ -f "app/build.gradle" ]; then
    cp app/build.gradle app/build.gradle.backup
    echo "✅ Sauvegarde de app/build.gradle effectuée"
fi

# =============================================================================
# ÉTAPE 2: Création du fichier .gitignore
# =============================================================================
echo ""
echo "📝 ÉTAPE 2: Création du fichier .gitignore..."

cat > .gitignore << 'GITIGNORE_EOF'
# Keystore
*.keystore
*.jks
keystore.properties

# Build
build/
.gradle/
local.properties

# IDE
.idea/
*.iml
*.ipr
*.iws

# OS
.DS_Store
Thumbs.db

# Logs
*.log
GITIGNORE_EOF

echo "✅ Fichier .gitignore créé"

# =============================================================================
# ÉTAPE 3: Mise à jour du build.gradle (racine)
# =============================================================================
echo ""
echo "🔧 ÉTAPE 3: Mise à jour du build.gradle (racine)..."

cat > build.gradle << 'BUILD_GRADLE_EOF'
buildscript {
    ext.kotlin_version = "1.8.10"
    repositories {
        google()
        mavenCentral()
        maven { url "https://jitpack.io" }
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:7.3.1'
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url "https://jitpack.io" }
    }
}

task clean(type: Delete) {
    delete rootProject.buildDir
}
BUILD_GRADLE_EOF

echo "✅ build.gradle (racine) mis à jour"

# =============================================================================
# ÉTAPE 4: Mise à jour du app/build.gradle avec configuration de signature
# =============================================================================
echo ""
echo "📱 ÉTAPE 4: Mise à jour du app/build.gradle..."

cat > app/build.gradle << 'APP_BUILD_GRADLE_EOF'
plugins {
    id 'com.android.application'
    id 'kotlin-android'
}

android {
    compileSdk 34

    signingConfigs {
        release {
            def keystorePropertiesFile = rootProject.file("app/keystore.properties")
            if (keystorePropertiesFile.exists()) {
                def keystoreProperties = new Properties()
                keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
                storeFile file(keystoreProperties['storeFile'])
                storePassword keystoreProperties['storePassword']
                keyAlias keystoreProperties['keyAlias']
                keyPassword keystoreProperties['keyPassword']
            }
        }
    }

    defaultConfig {
        applicationId "com.magiccontrol"
        minSdk 21
        targetSdk 34
        versionCode 1
        versionName "1.0"
        testInstrumentationRunner "androidx.test.runner.AndroidJUnitRunner"
    }

    buildTypes {
        release {
            minifyEnabled false
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
            signingConfig signingConfigs.release
        }
    }
    
    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }
    
    kotlinOptions {
        jvmTarget = '1.8'
    }
}

dependencies {
    implementation 'androidx.core:core-ktx:1.10.1'
    implementation 'androidx.appcompat:appcompat:1.6.1'
    implementation 'com.google.android.material:material:1.9.0'
    implementation 'androidx.constraintlayout:constraintlayout:2.1.4'
    implementation 'androidx.preference:preference-ktx:1.2.0'
    implementation 'androidx.activity:activity-ktx:1.7.2'
    implementation 'androidx.fragment:fragment-ktx:1.6.1'
    
    // Vosk
    implementation 'net.java.dev.jna:jna:5.13.0@aar'
    implementation(name: 'vosk-android', ext: 'aar')
    
    testImplementation 'junit:junit:4.13.2'
    androidTestImplementation 'androidx.test.ext:junit:1.1.5'
    androidTestImplementation 'androidx.test.espresso:espresso-core:3.5.1'
}
APP_BUILD_GRADLE_EOF

echo "✅ app/build.gradle mis à jour"

# =============================================================================
# ÉTAPE 5: Mise à jour du settings.gradle
# =============================================================================
echo ""
echo "⚙️ ÉTAPE 5: Mise à jour du settings.gradle..."

cat > settings.gradle << 'SETTINGS_GRADLE_EOF'
pluginManagement {
    repositories {
        gradlePluginPortal()
        google()
        mavenCentral()
    }
}
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
        maven { url "https://jitpack.io" }
    }
}
rootProject.name = "MagicControl"
include ':app'
SETTINGS_GRADLE_EOF

echo "✅ settings.gradle mis à jour"

# =============================================================================
# ÉTAPE 6: Mise à jour du gradle-wrapper.properties
# =============================================================================
echo ""
echo "📦 ÉTAPE 6: Mise à jour du gradle-wrapper.properties..."

mkdir -p gradle/wrapper

cat > gradle/wrapper/gradle-wrapper.properties << 'GRADLE_WRAPPER_EOF'
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-7.6.1-bin.zip
networkTimeout=10000
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
GRADLE_WRAPPER_EOF

echo "✅ gradle-wrapper.properties mis à jour"

# =============================================================================
# ÉTAPE 7: Création du gradle.properties
# =============================================================================
echo ""
echo "🔐 ÉTAPE 7: Création du gradle.properties..."

cat > gradle.properties << 'GRADLE_PROPERTIES_EOF'
# Project-wide Gradle settings.
org.gradle.jvmargs=-Xmx2048m -Dfile.encoding=UTF-8
android.useAndroidX=true
android.enableJetifier=true
android.nonTransitiveRClass=true
GRADLE_PROPERTIES_EOF

echo "✅ gradle.properties créé"

# =============================================================================
# ÉTAPE 8: Mise à jour du workflow GitHub Actions
# =============================================================================
echo ""
echo "🔄 ÉTAPE 8: Mise à jour du workflow GitHub Actions..."

mkdir -p .github/workflows

cat > .github/workflows/build.yml << 'WORKFLOW_EOF'
name: Build MagicControl

on:
  push:
    branches: [ main ]

jobs:
  build-android:
    runs-on: ubuntu-22.04
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up JDK 11
        uses: actions/setup-java@v4
        with:
          java-version: '11'
          distribution: 'temurin'
          
      - name: Grant execute permission for gradlew
        run: chmod +x gradlew
        
      - name: Clean Gradle Cache
        run: |
          ./gradlew clean
          rm -rf ~/.gradle/caches/
          
      - name: Create keystore
        run: |
          keytool -genkey -v \
            -keystore app/release.keystore \
            -alias release \
            -keyalg RSA \
            -keysize 2048 \
            -validity 10000 \
            -storepass ${{ secrets.KEYSTORE_PASSWORD }} \
            -keypass ${{ secrets.KEY_PASSWORD }} \
            -dname "CN=MagicControl, OU=MagicControl, O=MagicControl, L=Paris, ST=France, C=FR"
            
      - name: Create keystore properties
        run: |
          echo "storeFile=release.keystore" > app/keystore.properties
          echo "storePassword=${{ secrets.KEYSTORE_PASSWORD }}" >> app/keystore.properties
          echo "keyAlias=release" >> app/keystore.properties
          echo "keyPassword=${{ secrets.KEY_PASSWORD }}" >> app/keystore.properties
          
      - name: Verify keystore creation
        run: |
          if [ ! -f "app/release.keystore" ]; then
            echo "Keystore not created!"
            exit 1
          fi
          if [ ! -f "app/keystore.properties" ]; then
            echo "Keystore properties not created!"
            exit 1
          fi
          echo "Keystore and properties created successfully"
          
      - name: Build APK
        run: |
          ./gradlew assembleRelease --info --stacktrace
          
      - name: Verify APK creation
        run: |
          if [ ! -f "app/build/outputs/apk/release/app-release.apk" ]; then
            echo "APK not found!"
            exit 1
          fi
          echo "APK created successfully"
          
      - name: Upload build log
        uses: actions/upload-artifact@v4
        with:
          name: build-logs
          path: build.log
          
      - name: Upload APK
        uses: actions/upload-artifact@v4
        with:
          name: magiccontrol-android
          path: app/build/outputs/apk/release/app-release.apk
WORKFLOW_EOF

echo "✅ Workflow GitHub Actions mis à jour"

# =============================================================================
# ÉTAPE 9: Nettoyage et vérification finale
# =============================================================================
echo ""
echo "🧹 ÉTAPE 9: Nettoyage et vérification finale..."

# Nettoyer les fichiers temporaires
rm -f build.log 2>/dev/null
rm -rf app/build 2>/dev/null
rm -rf .gradle 2>/dev/null

# Vérifier que tous les fichiers ont été créés
files=(
    ".gitignore"
    "build.gradle"
    "app/build.gradle"
    "settings.gradle"
    "gradle/wrapper/gradle-wrapper.properties"
    "gradle.properties"
    ".github/workflows/build.yml"
)

echo ""
echo "🔍 Vérification des fichiers créés..."

all_files_exist=true
for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file"
    else
        echo "❌ $file (manquant)"
        all_files_exist=false
    fi
done

if [ "$all_files_exist" = true ]; then
    echo ""
    echo "🎉 Toutes les corrections ont été appliquées avec succès!"
    
    # =============================================================================
    # ÉTAPE 10: PUSH VERS GITHUB
    # =============================================================================
    echo ""
    echo "📤 ÉTAPE 10: Push des modifications vers GitHub..."
    
    # Vérifier si on est dans un dépôt git
    if [ ! -d ".git" ]; then
        echo "❌ Ce répertoire n'est pas un dépôt Git"
        exit 1
    fi
    
    # Ajouter et committer chaque fichier individuellement comme vous le faites
    echo ""
    echo "📝 Commit des fichiers individuels..."
    
    git add .gitignore && git commit -m "📝 Add .gitignore for Android project" && echo "✅ .gitignore committed"
    git add build.gradle && git commit -m "🔧 Fix: update root build.gradle for GitHub compatibility" && echo "✅ build.gradle committed"
    git add app/build.gradle && git commit -m "📱 Fix: update app build.gradle with signing config" && echo "✅ app/build.gradle committed"
    git add settings.gradle && git commit -m "⚙️ Fix: update settings.gradle for proper configuration" && echo "✅ settings.gradle committed"
    git add gradle/wrapper/gradle-wrapper.properties && git commit -m "📦 Fix: update gradle wrapper to 7.6.1" && echo "✅ gradle-wrapper.properties committed"
    git add gradle.properties && git commit -m "🔐 Add gradle.properties for project configuration" && echo "✅ gradle.properties committed"
    git add .github/workflows/build.yml && git commit -m "🔄 Add GitHub Actions workflow for APK build" && echo "✅ GitHub Actions workflow committed"
    
    echo ""
    echo "🚀 Push vers GitHub..."
    git push origin main
    
    if [ $? -eq 0 ]; then
        echo ""
        echo "🎉 Tous les fichiers ont été poussés vers GitHub avec succès!"
        echo ""
        echo "📋 ÉTAPES SUIVANTES REQUISES:"
        echo "1. Allez dans votre dépôt GitHub: https://github.com/broken2909/no-see-clean"
        echo "2. Cliquez sur l'onglet 'Actions' pour voir le build en cours"
        echo "3. Créez les secrets GitHub dans Settings > Secrets and variables > Actions:"
        echo "   - KEYSTORE_PASSWORD: une valeur sécurisée (ex: MySecurePassword123)"
        echo "   - KEY_PASSWORD: la même valeur"
        echo ""
        echo "🔗 Lien direct vers Actions: https://github.com/broken2909/no-see-clean/actions"
    else
        echo "❌ Erreur lors du push vers GitHub"
        exit 1
    fi
else
    echo ""
    echo "⚠️ Certains fichiers n'ont pas été créés correctement."
    echo "Vérifiez les erreurs ci-dessus et réexécutez le script."
    exit 1
fi

echo ""
echo "✅ Script de correction terminé avec succès!"
