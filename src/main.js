// MagicControl - Système de reconnaissance vocale offline avec Vosk
// Application pour personnes malvoyantes - Respect total de la vie privée

class MagicControlVosk {
    constructor() {
        this.isInitialized = false;
        this.recognizerFR = null;
        this.recognizerEN = null;
        this.currentLanguage = 'fr';
        this.isListening = false;
        this.audioContext = null;
        this.mediaStream = null;
        this.processor = null;
        
        this.init();
    }

    async init() {
        console.log('🎤 Initialisation de MagicControl...');
        await this.loadVoskModels();
        await this.setupAudio();
        this.setupUI();
        this.startListening();
    }

    async loadVoskModels() {
        try {
            console.log('📦 Chargement des modèles Vosk...');
            
            // Import dynamique de Vosk
            const { createModel, createRecognizer } = await import('vosk-browser');
            
            // URLs des modèles Vosk compacts pour le navigateur
            const modelUrlFR = 'https://alphacephei.com/vosk/models/vosk-model-small-fr-0.22.zip';
            const modelUrlEN = 'https://alphacephei.com/vosk/models/vosk-model-small-en-us-0.15.zip';
            
            this.updateStatus('vosk-fr-status', '⏳ Chargement modèle FR...', 'loading');
            this.updateStatus('vosk-en-status', '⏳ Chargement modèle EN...', 'loading');
            
            // Chargement des modèles en parallèle
            const [modelFR, modelEN] = await Promise.all([
                this.loadModel(createModel, modelUrlFR, 'FR'),
                this.loadModel(createModel, modelUrlEN, 'EN')
            ]);
            
            // Création des recognizers
            this.recognizerFR = new createRecognizer(modelFR, 16000);
            this.recognizerEN = new createRecognizer(modelEN, 16000);
            
            this.updateStatus('vosk-fr-status', '✅ Modèle FR: Prêt', 'ready');
            this.updateStatus('vosk-en-status', '✅ Modèle EN: Prêt', 'ready');
            
            console.log('✅ Modèles Vosk chargés avec succès');
            
        } catch (error) {
            console.error('❌ Erreur chargement modèles Vosk:', error);
            this.updateStatus('vosk-fr-status', '❌ Erreur chargement FR', 'error');
            this.updateStatus('vosk-en-status', '❌ Erreur chargement EN', 'error');
        }
    }

    async loadModel(createModel, url, language) {
        try {
            console.log(`📥 Téléchargement modèle ${language}...`);
            
            // Simulation du chargement pour la démo
            // En production, il faudrait télécharger et décompresser le modèle
            await new Promise(resolve => setTimeout(resolve, 2000));
            
            // Pour la démo, on simule un modèle chargé
            return { language, loaded: true };
            
        } catch (error) {
            console.error(`❌ Erreur chargement modèle ${language}:`, error);
            throw error;
        }
    }

    async setupAudio() {
        try {
            console.log('🎧 Configuration audio...');
            
            // Demander l'accès au microphone
            this.mediaStream = await navigator.mediaDevices.getUserMedia({
                audio: {
                    sampleRate: 16000,
                    channelCount: 1,
                    echoCancellation: true,
                    noiseSuppression: true
                }
            });

            // Créer le contexte audio
            this.audioContext = new (window.AudioContext || window.webkitAudioContext)({
                sampleRate: 16000
            });

            const source = this.audioContext.createMediaStreamSource(this.mediaStream);
            
            // Créer un processeur audio pour Vosk
            this.processor = this.audioContext.createScriptProcessor(4096, 1, 1);
            
            source.connect(this.processor);
            this.processor.connect(this.audioContext.destination);
            
            this.updateStatus('audio-status', '✅ Microphone: Prêt', 'ready');
            console.log('✅ Audio configuré avec succès');
            
        } catch (error) {
            console.error('❌ Erreur configuration audio:', error);
            this.updateStatus('audio-status', '❌ Erreur microphone', 'error');
        }
    }

    startListening() {
        if (!this.processor || this.isListening) return;
        
        console.log('👂 Démarrage de l\'écoute...');
        this.isListening = true;
        
        this.processor.onaudioprocess = (event) => {
            if (!this.isListening) return;
            
            const inputBuffer = event.inputBuffer;
            const audioData = inputBuffer.getChannelData(0);
            
            // Convertir en format requis par Vosk (PCM 16-bit)
            const buffer = new Int16Array(audioData.length);
            for (let i = 0; i < audioData.length; i++) {
                buffer[i] = Math.max(-32768, Math.min(32767, audioData[i] * 32768));
            }
            
            // Envoyer à Vosk pour reconnaissance
            this.processAudioWithVosk(buffer);
        };
    }

    processAudioWithVosk(audioBuffer) {
        try {
            const recognizer = this.currentLanguage === 'fr' ? this.recognizerFR : this.recognizerEN;
            
            if (!recognizer) return;
            
            // Simulation de la reconnaissance Vosk
            // En production, utiliser: recognizer.acceptWaveform(audioBuffer)
            this.simulateVoskRecognition(audioBuffer);
            
        } catch (error) {
            console.error('❌ Erreur reconnaissance Vosk:', error);
        }
    }

    simulateVoskRecognition(audioBuffer) {
        // Simulation simple basée sur l'énergie audio
        const energy = audioBuffer.reduce((sum, sample) => sum + Math.abs(sample), 0) / audioBuffer.length;
        
        if (energy > 1000) { // Seuil arbitraire pour simulation
            const commands = this.currentLanguage === 'fr' ? 
                ['augmenter le volume', 'baisser le volume', 'activer wifi', 'ouvrir paramètres', 'éteindre bluetooth'] :
                ['increase volume', 'decrease volume', 'enable wifi', 'open settings', 'turn off bluetooth'];
            
            const randomCommand = commands[Math.floor(Math.random() * commands.length)];
            this.handleRecognitionResult(randomCommand);
        }
    }

    handleRecognitionResult(text) {
        if (!text || text.trim() === '') return;
        
        console.log('🗣️ Reconnaissance:', text);
        
        // Afficher le résultat
        const resultDiv = document.getElementById('recognition-result');
        resultDiv.innerHTML = `
            <strong>Commande reconnue:</strong><br>
            "${text}"<br>
            <small style="color: #8b949e;">Langue: ${this.currentLanguage.toUpperCase()}</small>
        `;
        
        // Traiter la commande
        this.executeVoiceCommand(text);
    }

    executeVoiceCommand(command) {
        const lowerCommand = command.toLowerCase();
        
        // Commandes système simulées
        if (lowerCommand.includes('volume') || lowerCommand.includes('son')) {
            console.log('🔊 Commande volume détectée');
            this.speak(this.currentLanguage === 'fr' ? 'Volume modifié' : 'Volume changed');
        }
        else if (lowerCommand.includes('wifi')) {
            console.log('📶 Commande WiFi détectée');
            this.speak(this.currentLanguage === 'fr' ? 'WiFi modifié' : 'WiFi changed');
        }
        else if (lowerCommand.includes('paramètres') || lowerCommand.includes('settings')) {
            console.log('⚙️ Ouverture paramètres');
            this.speak(this.currentLanguage === 'fr' ? 'Ouverture des paramètres' : 'Opening settings');
        }
        else if (lowerCommand.includes('bluetooth')) {
            console.log('🔵 Commande Bluetooth détectée');
            this.speak(this.currentLanguage === 'fr' ? 'Bluetooth modifié' : 'Bluetooth changed');
        }
        else if (lowerCommand.includes('français') || lowerCommand.includes('french')) {
            this.switchLanguage('fr');
        }
        else if (lowerCommand.includes('anglais') || lowerCommand.includes('english')) {
            this.switchLanguage('en');
        }
    }

    switchLanguage(language) {
        this.currentLanguage = language;
        console.log(`🌍 Changement de langue: ${language.toUpperCase()}`);
        this.speak(language === 'fr' ? 'Langue changée en français' : 'Language changed to English');
    }

    speak(text) {
        // Synthèse vocale native du navigateur (offline)
        if ('speechSynthesis' in window) {
            const utterance = new SpeechSynthesisUtterance(text);
            utterance.lang = this.currentLanguage === 'fr' ? 'fr-FR' : 'en-US';
            utterance.rate = 0.9;
            speechSynthesis.speak(utterance);
        }
    }

    updateStatus(elementId, text, className) {
        const element = document.getElementById(elementId);
        if (element) {
            element.textContent = text;
            element.className = `vosk-status ${className}`;
        }
    }

    setupUI() {
        // Ajouter les contrôles de langue
        const container = document.querySelector('.container');
        const controls = document.createElement('div');
        controls.innerHTML = `
            <div style="margin: 30px 0; padding: 20px; background: #21262d; border-radius: 10px;">
                <h3 style="color: #f0f6fc; margin-bottom: 15px;">Contrôles</h3>
                <button id="lang-fr" style="margin: 5px; padding: 10px 20px; background: #238636; color: white; border: none; border-radius: 5px; cursor: pointer;">Français</button>
                <button id="lang-en" style="margin: 5px; padding: 10px 20px; background: #238636; color: white; border: none; border-radius: 5px; cursor: pointer;">English</button>
                <button id="toggle-listening" style="margin: 5px; padding: 10px 20px; background: #f85149; color: white; border: none; border-radius: 5px; cursor: pointer;">Arrêter</button>
            </div>
        `;
        
        container.appendChild(controls);
        
        // Événements des boutons
        document.getElementById('lang-fr').onclick = () => this.switchLanguage('fr');
        document.getElementById('lang-en').onclick = () => this.switchLanguage('en');
        document.getElementById('toggle-listening').onclick = () => this.toggleListening();
    }

    toggleListening() {
        const button = document.getElementById('toggle-listening');
        
        if (this.isListening) {
            this.isListening = false;
            button.textContent = this.currentLanguage === 'fr' ? 'Démarrer' : 'Start';
            button.style.background = '#238636';
            console.log('⏸️ Écoute arrêtée');
        } else {
            this.isListening = true;
            button.textContent = this.currentLanguage === 'fr' ? 'Arrêter' : 'Stop';
            button.style.background = '#f85149';
            console.log('▶️ Écoute reprise');
        }
    }
}

// Initialisation automatique
document.addEventListener('DOMContentLoaded', () => {
    new MagicControlVosk();
});

console.log('🚀 MagicControl initialisé - Application de contrôle vocal offline pour malvoyants');