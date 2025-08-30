#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

console.log('🔍 Preparing AWS Amplify deployment...');

// Create .amplify-hosting directory
const amplifyHostingPath = path.join(process.cwd(), '.amplify-hosting');
fs.mkdirSync(amplifyHostingPath, { recursive: true });

// Create deploy-manifest.json with complete structure
const deployManifest = {
  version: 1,
  routes: [
    {
      path: "/*",
      target: {
        kind: "Compute",
        src: "default"
      }
    }
  ],
  computeResources: [
    {
      name: "default",
      runtime: "nodejs20.x",
      entrypoint: "server.js",
      buildFiles: [
        "**/*"
      ]
    }
  ],
  framework: {
    name: "next",
    version: require('../package.json').dependencies.next.replace('^', '')
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
  
  // Copy the entire standalone directory contents (not the directory itself)
  const standaloneContents = fs.readdirSync(standalonePath);
  standaloneContents.forEach(item => {
    const srcPath = path.join(standalonePath, item);
    const destPath = path.join(amplifyHostingPath, item);
    fs.cpSync(srcPath, destPath, { recursive: true });
  });
  
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
    fs.mkdirSync(path.dirname(destPublicPath), { recursive: true });
    fs.cpSync(publicPath, destPublicPath, { recursive: true });
  }
  
  // Verify server.js exists at the root
  const serverJsPath = path.join(amplifyHostingPath, 'server.js');
  if (!fs.existsSync(serverJsPath)) {
    console.log('⚠️  server.js not found at root, looking for it...');
    const webServerJs = path.join(amplifyHostingPath, 'web', 'server.js');
    if (fs.existsSync(webServerJs)) {
      console.log('📋 Moving server.js to root...');
      fs.copyFileSync(webServerJs, serverJsPath);
    }
  }
  
  console.log('✅ Copied standalone build files');
  console.log('📁 .amplify-hosting structure:');
  console.log(fs.readdirSync(amplifyHostingPath).join('\n'));
} else {
  console.log('❌ No standalone build found. Make sure output: "standalone" is set in next.config.js');
}

console.log('🎉 Amplify deployment preparation complete');
