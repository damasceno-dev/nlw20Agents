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
  // AWS Amplify WEB_COMPUTE requires standalone output
  output: 'standalone',
};

export default nextConfig;
