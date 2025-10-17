#!/usr/bin/env node

import { spawn } from 'child_process';
import { existsSync } from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

console.log('🚀 Starting RJB TRANZ Desktop Development Environment...\n');

// Check if Electron is installed
const electronPath = path.join(__dirname, '..', 'node_modules', '.bin', 'electron');
if (!existsSync(electronPath) && !existsSync(electronPath + '.cmd')) {
  console.error('❌ Electron not found. Please run: npm install');
  process.exit(1);
}

// Check if main.js exists
const mainPath = path.join(__dirname, '..', 'electron', 'main.js');
if (!existsSync(mainPath)) {
  console.error('❌ Electron main.js not found at:', mainPath);
  process.exit(1);
}

// Start Vite dev server
console.log('📦 Starting Vite development server...');
const viteProcess = spawn('npm', ['run', 'dev'], {
  stdio: 'pipe',
  cwd: path.join(__dirname, '..')
});

let viteReady = false;

viteProcess.stdout.on('data', (data) => {
  const output = data.toString();
  console.log('📦 Vite:', output.trim());
  
  // Check if Vite is ready
  if (output.includes('Local:') && output.includes('5173') && !viteReady) {
    viteReady = true;
    console.log('\n⚡ Vite ready! Starting Electron...\n');
    
    // Start Electron after a short delay
    setTimeout(() => {
      const electronProcess = spawn('electron', ['.'], {
        stdio: 'inherit',
        cwd: path.join(__dirname, '..')
      });

      electronProcess.on('close', (code) => {
        console.log('\n🔚 Electron closed with code:', code);
        viteProcess.kill();
        process.exit(code);
      });
    }, 1000);
  }
});

viteProcess.stderr.on('data', (data) => {
  console.error('📦 Vite Error:', data.toString().trim());
});

viteProcess.on('close', (code) => {
  console.log('\n📦 Vite process closed with code:', code);
  process.exit(code);
});

// Handle cleanup
process.on('SIGINT', () => {
  console.log('\n🛑 Shutting down development environment...');
  viteProcess.kill();
  process.exit(0);
});

process.on('SIGTERM', () => {
  console.log('\n🛑 Shutting down development environment...');
  viteProcess.kill();
  process.exit(0);
});