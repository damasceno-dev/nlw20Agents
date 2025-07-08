# 🚀 Let Me Ask - AI-Powered Room Management System

A modern, full-stack web application built with Next.js 15, featuring AI-powered room management, real-time interactions, and a beautiful dark-themed UI.

![Next.js](https://img.shields.io/badge/Next.js-15.3.5-black?style=for-the-badge&logo=next.js)
![React](https://img.shields.io/badge/React-19.0.0-61DAFB?style=for-the-badge&logo=react)
![TypeScript](https://img.shields.io/badge/TypeScript-5.0-blue?style=for-the-badge&logo=typescript)
![Tailwind CSS](https://img.shields.io/badge/Tailwind_CSS-4.0-38B2AC?style=for-the-badge&logo=tailwind-css)

## ✨ Features

- 🎨 **Modern Dark UI** - Beautiful dark theme with smooth transitions
- 🏠 **Room Management** - Create, view, and manage AI-powered rooms
- 🔄 **Real-time Updates** - Live data synchronization with React Query
- 📱 **Responsive Design** - Works perfectly on all devices
- ⚡ **Performance Optimized** - Server-side rendering with Next.js 15
- 🔧 **Type-Safe API** - Auto-generated TypeScript API client with Orval
- 🎯 **Smart Linting** - Biome for fast, reliable code formatting
- 🚀 **Turbopack** - Lightning-fast development with Next.js Turbopack

## 🛠️ Tech Stack

### Frontend
- **Next.js 15** - React framework with App Router
- **React 19** - Latest React with concurrent features
- **TypeScript** - Type-safe development
- **Tailwind CSS 4** - Utility-first CSS framework
- **Lucide React** - Beautiful icon library

### State Management & API
- **React Query (TanStack Query)** - Server state management
- **Axios** - HTTP client for API requests
- **Orval** - Auto-generated TypeScript API client

### Development Tools
- **Biome** - Fast linter and formatter
- **Turbopack** - Next.js bundler for faster development
- **Ultracite** - Advanced code quality rules

## 🚀 Quick Start

### Prerequisites
- Node.js 18+ 
- npm, yarn, pnpm, or bun

### Installation

1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
   cd web
   ```

2. **Install dependencies**
   ```bash
   npm install
   # or
   yarn install
   # or
   pnpm install
   ```

3. **Set up environment variables**
   ```bash
   cp .env.example .env.local
   ```
   
   Add your API URL:
   ```env
   NEXT_PUBLIC_API_URL=http://localhost:5130
   ```

4. **Start the development server**
   ```bash
   npm run dev
   # or
   yarn dev
   # or
   pnpm dev
   ```

5. **Open your browser**
   Navigate to [http://localhost:3000](http://localhost:3000)

## 📁 Project Structure

```
src/
├── app/                    # Next.js App Router pages
│   ├── create-room/       # Room listing page
│   ├── room/[id]/         # Individual room page
│   ├── globals.css        # Global styles
│   └── layout.tsx         # Root layout
├── api/                   # API integration
│   ├── generated/         # Auto-generated API client
│   └── mutator/           # Custom API instance
├── providers/             # React providers
│   └── query-provider.tsx # React Query provider
└── lib/                   # Utility functions
```

## 🔧 Available Scripts

| Script | Description |
|--------|-------------|
| `npm run dev` | Start development server with Turbopack |
| `npm run dev:https` | Start with HTTPS (for secure API calls) |
| `npm run build` | Build for production |
| `npm run start` | Start production server |
| `npm run lint` | Run Biome linter |
| `npm run generate-api:dev-http` | Generate API client from Swagger |

## 🎨 UI Components

The project uses a modern design system with:

- **Dark Theme** - Easy on the eyes with beautiful contrast
- **Responsive Grid** - Adaptive layouts for all screen sizes
- **Smooth Animations** - Enhanced user experience with transitions
- **Accessible Design** - WCAG compliant components

## 🔌 API Integration

The project features a robust API integration system:

- **Auto-generated Client** - TypeScript API client generated from Swagger/OpenAPI
- **React Query Integration** - Efficient caching and state management
- **Error Handling** - Graceful error boundaries and fallbacks
- **Type Safety** - Full TypeScript support for API responses

## 🚀 Deployment

### Vercel (Recommended)
```bash
npm run build
vercel --prod
```

### Other Platforms
The app can be deployed to any platform that supports Next.js:
- Netlify
- Railway
- DigitalOcean App Platform
- AWS Amplify

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Next.js](https://nextjs.org/) - The React framework
- [Tailwind CSS](https://tailwindcss.com/) - Utility-first CSS framework
- [Vercel](https://vercel.com/) - Deployment platform
- [Biome](https://biomejs.dev/) - Fast linter and formatter

---

<div align="center">
  <p>Made with ❤️ using Next.js and modern web technologies</p>
  <p>⭐ Star this repo if you found it helpful!</p>
</div>
