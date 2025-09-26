import { defineConfig } from 'vite'

export default defineConfig({
  server: {
    headers: {
      'Cross-Origin-Embedder-Policy': 'require-corp',
      'Cross-Origin-Opener-Policy': 'same-origin',
    }
  },
  optimizeDeps: {
    exclude: ['vosk-browser']
  },
  build: {
    target: 'esnext',
    rollupOptions: {
      output: {
        format: 'es'
      }
    }
  }
})