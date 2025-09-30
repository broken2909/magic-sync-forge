#!/bin/bash
echo "🔍 VÉRIFICATION COMPLÈTE DE L'HARMONISATION..."

echo "🎨 1. VÉRIFICATION DES COULEURS RÉFÉRENCÉES..."
echo "=============================================="

# Vérifier toutes les couleurs utilisées dans les layouts
echo "📱 Couleurs dans activity_main.xml:"
grep -o '@color/[^"]*' app/src/main/res/layout/activity_main.xml | sort -u

echo ""
echo "🎨 Couleurs dans les drawables:"
grep -h -o '#[0-9a-fA-F]\{6\}' app/src/main/res/drawable/*.xml 2>/dev/null | sort -u

echo ""
echo "📊 2. VÉRIFICATION DES RESSOURCES EXISTANTES..."
echo "=============================================="

# Vérifier que toutes les couleurs référencées existent
echo "🎯 Couleurs déclarées dans colors.xml:"
grep 'name="' app/src/main/res/values/colors.xml | sed 's/.*name="//' | sed 's/".*//'

echo ""
echo "📝 3. VÉRIFICATION DES STRINGS RÉFÉRENCÉS..."
echo "==========================================="

# Vérifier les strings dans le layout
echo "📱 Strings dans activity_main.xml:"
grep -o '@string/[^"]*' app/src/main/res/layout/activity_main.xml | sed 's/@string\///' | sort -u

echo ""
echo "🎯 Strings déclarés dans strings.xml:"
grep 'name="' app/src/main/res/values/strings.xml | sed 's/.*name="//' | sed 's/".*//' | head -10

echo ""
echo "✅ 4. VALIDATION XML GLOBALE..."
echo "==============================="

# Validation de tous les XML
for xml_file in app/src/main/res/layout/*.xml app/src/main/res/drawable/*.xml; do
    if [ -f "$xml_file" ]; then
        if xmllint --noout "$xml_file" >/dev/null 2>&1; then
            echo "✅ $(basename "$xml_file")"
        else
            echo "❌ $(basename "$xml_file")"
        fi
    fi
done

echo ""
echo "🎯 RÉSUMÉ DE L'HARMONISATION"
