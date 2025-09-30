import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig(({ command }) => ({
  plugins: [react()],
  // Em dev: "/", em build: "/area-do-cliente/"
  base: command === 'build' ? '/area-do-cliente/' : '/',
  build: { assetsDir: 'assets' },
}))
