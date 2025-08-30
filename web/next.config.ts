import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  /* config options here */
  webpack: (config) => {
    // Add explicit alias for @ imports to ensure they work in all environments
    config.resolve.alias = {
      ...config.resolve.alias,
      '@': require('path').resolve(__dirname, './src'),
    };
    return config;
  },
  // AWS Amplify now has native Next.js support
  // No special output configuration needed
};

export default nextConfig;
