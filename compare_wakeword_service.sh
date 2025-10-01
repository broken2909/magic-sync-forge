#!/bin/bash
echo "🔍 COMPARAISON WAKEOWORD SERVICE"

echo ""
echo "📋 VERSION ACTUELLE :"
cat app/src/main/java/com/magiccontrol/service/WakeWordService.kt

echo ""
echo "📋 VERSION COMMIT bb1993f :"
git show bb1993f:app/src/main/java/com/magiccontrol/service/WakeWordService.kt 2>/dev/null || echo "❌ Commit bb1993f non trouvé"

echo ""
echo "🎯 RECHERCHE DU BON COMMIT :"
git log --oneline --grep="WakeWordService" --all -5
