# Build stage
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

# Copy csproj and restore dependencies
COPY ["Dokploy Tests.csproj", "./"]
RUN dotnet restore "Dokploy Tests.csproj"

# Copy everything else and build
COPY . .
RUN dotnet build "Dokploy Tests.csproj" -c Release -o /app/build

# Publish stage
FROM build AS publish
RUN dotnet publish "Dokploy Tests.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS final
WORKDIR /app
EXPOSE 8080
EXPOSE 8081

# Copy published app from publish stage
COPY --from=publish /app/publish .

# Set entry point
ENTRYPOINT ["dotnet", "Dokploy Tests.dll"]
