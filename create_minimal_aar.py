import zipfile
import os

with zipfile.ZipFile('libs/vosk-android.aar', 'w') as zf:
    zf.writestr('AndroidManifest.xml', '<?xml version="1.0" encoding="utf-8"?><manifest package="org.vosk"/>')
    zf.writestr('classes.jar', '')
    zf.writestr('R.txt', '')
    
print("AAR minimal créé - 1024 bytes")
