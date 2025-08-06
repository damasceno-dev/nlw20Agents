FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build-env

WORKDIR /app
COPY ["server.API/", "server.API/"]
COPY ["server.Communication/", "server.Communication/"]
COPY ["server.Application/", "server.Application/"]
COPY ["server.Domain/", "server.Domain/"]
COPY ["server.Exceptions/", "server.Exceptions/"]
COPY ["server.Infrastructure/", "server.Infrastructure/"]
RUN dotnet restore "server.API/server.API.csproj"

WORKDIR server.API/

RUN dotnet restore
RUN dotnet publish -c Release -o /app/out

FROM mcr.microsoft.com/dotnet/aspnet:9.0
WORKDIR /app

COPY --from=build-env /app/out .

ENTRYPOINT ["dotnet", "server.API.dll"]