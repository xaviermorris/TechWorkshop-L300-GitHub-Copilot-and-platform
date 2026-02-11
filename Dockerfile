# Multi-stage build for ZavaStorefront container
FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app
EXPOSE 8080
ENV ASPNETCORE_URLS=http://+:8080

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src
COPY ["src/ZavaStorefront.csproj", "src/"]
RUN dotnet restore "src/ZavaStorefront.csproj"
COPY . .
RUN dotnet build "src/ZavaStorefront.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "src/ZavaStorefront.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "ZavaStorefront.dll"]
