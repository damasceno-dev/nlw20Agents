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
  // Optimize output for AWS Amplify
  output: 'standalone',
};

export default nextConfig;
