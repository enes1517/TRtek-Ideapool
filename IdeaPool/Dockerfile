# Build Stage
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy all project files to restore them efficiently
COPY ["IdeaPool/IdeaPool.csproj", "IdeaPool/"]
COPY ["Entities/Entities.csproj", "Entities/"]
COPY ["Repositories/Repositories.csproj", "Repositories/"]
COPY ["Services/Services.csproj", "Services/"]

RUN dotnet restore "IdeaPool/IdeaPool.csproj"

# Copy everything else and build
COPY . .
WORKDIR "/src/IdeaPool"
RUN dotnet publish "IdeaPool.csproj" -c Release -o /app/publish

# Runtime Stage
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app
COPY --from=build /app/publish .

# Expose HTTP port 5139
EXPOSE 5139
ENV ASPNETCORE_URLS=http://+:5139

ENTRYPOINT ["dotnet", "IdeaPool.dll"]
