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

    // Copy static files to root .next/static (where standalone server expects them)
    const staticPath = path.join(process.cwd(), '.next', 'static');
    if (fs.existsSync(staticPath)) {
        const destStaticPath = path.join(computePath, '.next', 'static');
        fs.mkdirSync(path.dirname(destStaticPath), { recursive: true });
        fs.cpSync(staticPath, destStaticPath, { recursive: true });
        console.log('✅ Copied static files to root .next/static');
    }

    // Copy public directory if it exists
    const publicPath = path.join(process.cwd(), 'public');
    if (fs.existsSync(publicPath)) {
        const destPublicPath = path.join(computePath, 'public');
        fs.cpSync(publicPath, destPublicPath, { recursive: true });
        console.log('✅ Copied public directory');
    }

    // Ensure server.js exists at the root of compute/default
    const serverJsPath = path.join(computePath, 'server.js');
    if (!fs.existsSync(serverJsPath)) {
        const webServerJs = path.join(computePath, 'web', 'server.js');
        if (fs.existsSync(webServerJs)) {
            console.log('📋 Moving server.js to compute/default root...');
            fs.copyFileSync(webServerJs, serverJsPath);
        }
    }

    console.log('✅ Deployment preparation complete');
    console.log('📁 Structure created:');
    console.log('  .amplify-hosting/');
    console.log('    ├── deploy-manifest.json');
    console.log('    └── compute/default/');
    console.log('        ├── server.js');
    console.log('        ├── .next/static/');
    console.log('        └── public/');
} else {
    console.log('❌ No standalone build found. Make sure output: "standalone" is set in next.config.js');
}

console.log('🎉 Done!');