#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

console.log('🔍 Preparing AWS Amplify deployment...');

// Create .amplify-hosting directory
const amplifyHostingPath = path.join(process.cwd(), '.amplify-hosting');
fs.mkdirSync(amplifyHostingPath, { recursive: true });

// Create deploy-manifest.json
const deployManifest = {
  version: 1,
  framework: {
    name: 'next',
    version: require('../package.json').dependencies.next
  }
};

fs.writeFileSync(
  path.join(amplifyHostingPath, 'deploy-manifest.json'),
  JSON.stringify(deployManifest, null, 2)
);

console.log('✅ Created deploy-manifest.json');

// Copy standalone build output
const standalonePath = path.join(process.cwd(), '.next', 'standalone');
if (fs.existsSync(standalonePath)) {
  console.log('📁 Found standalone build, copying files...');
  
  // Copy the entire standalone directory
  fs.cpSync(standalonePath, amplifyHostingPath, { recursive: true });
  
  // Copy static files
  const staticPath = path.join(process.cwd(), '.next', 'static');
  if (fs.existsSync(staticPath)) {
    const destStaticPath = path.join(amplifyHostingPath, 'web', '.next', 'static');
    fs.mkdirSync(path.dirname(destStaticPath), { recursive: true });
    fs.cpSync(staticPath, destStaticPath, { recursive: true });
  }
  
  // Copy public directory
  const publicPath = path.join(process.cwd(), 'public');
  if (fs.existsSync(publicPath)) {
    const destPublicPath = path.join(amplifyHostingPath, 'web', 'public');
    fs.cpSync(publicPath, destPublicPath, { recursive: true });
  }
  
  console.log('✅ Copied standalone build files');
} else {
  console.log('❌ No standalone build found. Make sure output: "standalone" is set in next.config.js');
}

console.log('🎉 Amplify deployment preparation complete');
