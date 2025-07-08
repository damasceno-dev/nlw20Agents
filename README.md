# 🤖 NLW Agents - AI Meeting Room Platform

<p align="center">
  <img src="https://img.shields.io/badge/status-active-success.svg" alt="Status">
  <img src="https://img.shields.io/badge/platform-cross--platform-blue.svg" alt="Platform">
  <img src="https://img.shields.io/badge/made%20with-.NET%209-blueviolet.svg" alt="Made with .NET 9">
</p>

<p align="center">
  <img src="https://via.placeholder.com/800x400?text=NLW+Agents+Platform" alt="Project Banner">
</p>

## 🌟 Overview

NLW Agents is a cutting-edge platform that revolutionizes online meetings by leveraging AI capabilities to enhance collaboration. Built with a clean architecture approach using .NET 9, this platform provides a robust backend for managing AI-powered meeting rooms.

## ✨ Features

- **AI-Powered Meeting Rooms**: Create and manage specialized meeting rooms with AI agents
- **Clean Architecture**: Domain-driven design with clear separation of concerns
- **RESTful API**: Well-documented endpoints for easy frontend integration
- **Vector Database Integration**: Utilizes pgvector for advanced AI operations
- **Docker Support**: Easy setup and deployment with containerization
- **Development Tooling**: Seeding capabilities for quick development setup

## 🚀 Quick Start

### Prerequisites

- [.NET 9 SDK](https://dotnet.microsoft.com/download)
- [Docker](https://www.docker.com/get-started)
- [Docker Compose](https://docs.docker.com/compose/install/)

### Installation

1. Clone the repository
   ```bash
   git clone https://github.com/yourusername/nlw-agents.git
   cd nlw-agents
   ```

2. Start the database using Docker Compose
   ```bash
   docker-compose up -d
   ```

3. Seed the database (optional)
   ```bash
   cd server
   dotnet run --project server.API seed-database
   ```

4. Run the application
   ```bash
   dotnet run --project server.API
   ```

5. Access the API at `http://localhost:5130` or via Swagger at `http://localhost:5130/swagger`

## 🏗️ Architecture

The project follows Clean Architecture principles with these key components:

- **server.Domain**: Core entities and business rules
- **server.Application**: Use cases and application logic
- **server.Infrastructure**: External services and data access
- **server.API**: API controllers and middleware
- **server.Communication**: DTOs and response objects
- **server.Exceptions**: Custom exception handling

## 📝 API Documentation

Once the application is running, you can access the Swagger documentation at:

```
http://localhost:5130/swagger
```

Key endpoints include:

- `GET /rooms/getall`: Retrieve all available meeting rooms
- `POST /rooms`: Create a new meeting room (coming soon)
- `GET /healthcheck`: Verify API health status

## 🐳 Docker Integration

The project uses pgvector, a PostgreSQL extension that adds vector similarity search capabilities essential for AI operations.

```yaml
services: 
  nlw-agents-pg:
    image: pgvector/pgvector:pg17
    environment:
      POSTGRES_USER: docker
      POSTGRES_PASSWORD: docker
      POSTGRES_DB: agents
    ports:
      - "5432:5432"
```

## 🔧 Development

### Running in Development Mode

```bash
dotnet run --project server.API
```

### Environment Profiles

The application supports multiple environment profiles in `launchSettings.json`:

- **http**: Standard HTTP development profile
- **https**: HTTPS development profile
- **seed-database**: Special profile for database seeding

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📜 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgements

- [Rocketseat](https://rocketseat.com.br/) for the NLW event
- [.NET Team](https://dotnet.microsoft.com/) for the amazing framework
- [pgvector](https://github.com/pgvector/pgvector) for vector similarity search

---

<p align="center">
Built with ❤️ as part of the Next Level Week (NLW) event by Rocketseat
</p>
