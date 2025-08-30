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
      path: "/_next/static/*",
      target: {
        kind: "Static",
        src: "compute/default/web/.next/static"
      }
    },
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
      entrypoint: "server.js"
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

// Create compute directory
const computePath = path.join(amplifyHostingPath, 'compute', 'default');
fs.mkdirSync(computePath, { recursive: true });

// Copy standalone build output
const standalonePath = path.join(process.cwd(), '.next', 'standalone');
if (fs.existsSync(standalonePath)) {
  console.log('📁 Found standalone build, copying files...');
  
  // Copy the entire standalone directory to compute/default
  fs.cpSync(standalonePath, computePath, { recursive: true });
  
  // Copy static files
  const staticPath = path.join(process.cwd(), '.next', 'static');
  if (fs.existsSync(staticPath)) {
    const destStaticPath = path.join(computePath, 'web', '.next', 'static');
    fs.mkdirSync(path.dirname(destStaticPath), { recursive: true });
    fs.cpSync(staticPath, destStaticPath, { recursive: true });
    console.log('✅ Copied static files');
  }
  
  // Copy CSS files from .next/server/pages to ensure they're available
  const serverPagesPath = path.join(process.cwd(), '.next', 'server', 'app');
  if (fs.existsSync(serverPagesPath)) {
    const destServerPath = path.join(computePath, 'web', '.next', 'server', 'app');
    fs.mkdirSync(path.dirname(destServerPath), { recursive: true });
    fs.cpSync(serverPagesPath, destServerPath, { recursive: true });
    console.log('✅ Copied server app files');
  }
  
  // Copy public directory
  const publicPath = path.join(process.cwd(), 'public');
  if (fs.existsSync(publicPath)) {
    const destPublicPath = path.join(computePath, 'web', 'public');
    fs.mkdirSync(path.dirname(destPublicPath), { recursive: true });
    fs.cpSync(publicPath, destPublicPath, { recursive: true });
  }
  
  // Ensure server.js exists in compute/default
  const serverJsPath = path.join(computePath, 'server.js');
  if (!fs.existsSync(serverJsPath)) {
    console.log('⚠️  server.js not found, looking for it...');
    const webServerJs = path.join(computePath, 'web', 'server.js');
    if (fs.existsSync(webServerJs)) {
      console.log('📋 Moving server.js to compute/default root...');
      fs.copyFileSync(webServerJs, serverJsPath);
    }
  }
  
  console.log('✅ Copied standalone build files');
  console.log('📁 .amplify-hosting structure:');
  console.log(fs.readdirSync(amplifyHostingPath).join('\n'));
  console.log('📁 compute/default structure:');
  console.log(fs.readdirSync(computePath).join('\n'));
} else {
  console.log('❌ No standalone build found. Make sure output: "standalone" is set in next.config.js');
}

console.log('🎉 Amplify deployment preparation complete');
