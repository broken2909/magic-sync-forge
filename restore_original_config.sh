#!/bin/bash

echo "🔧 Réapplication EXACTE de votre configuration originale..."

# ÉTAPE 1: build.gradle racine (identique à votre original)
cat > build.gradle << 'EOF2'
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
EOF2

# ÉTAPE 2: settings.gradle (identique à votre original)
cat > settings.gradle << 'EOF2'
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
EOF2

# ÉTAPE 3: app/build.gradle (identique à votre original)
cat > app/build.gradle << 'EOF2'
plugins {
    id 'com.android.application'
    id 'kotlin-android'
}

android {
    compileSdk 34
    namespace 'com.magiccontrol'

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
    
    implementation 'net.java.dev.jna:jna:5.13.0@aar'
    implementation files('libs/vosk-android.aar')
}
EOF2

echo "✅ Configuration originale EXACTEMENT restaurée"
