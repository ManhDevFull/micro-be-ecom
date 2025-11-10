# ========================
# Stage 1: Build tất cả
# ========================
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

# Copy toàn bộ source
COPY dotnet/ ./dotnet/
COPY chat/ ./chat/
COPY gateway/ ./gateway/
COPY Contracts/ ./Contracts/

# Build dotnet
WORKDIR /src/dotnet
RUN dotnet restore dotnet.csproj
RUN dotnet publish dotnet.csproj -c Release -o /app/dotnet

# Build chat
WORKDIR /src/chat
RUN dotnet restore chat.csproj
RUN dotnet publish chat.csproj -c Release -o /app/chat

# Build gateway
WORKDIR /src/gateway
RUN dotnet restore gateway.csproj
RUN dotnet publish gateway.csproj -c Release -o /app/gateway

# ========================
# Stage 2: Runtime
# ========================
FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS final
WORKDIR /app

# Copy tất cả service
COPY --from=build /app/dotnet ./dotnet
COPY --from=build /app/chat ./chat
COPY --from=build /app/gateway ./gateway
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Cài đặt supervisor
RUN apt-get update && apt-get install -y supervisor && apt-get clean

EXPOSE 5200
CMD ["/usr/bin/supervisord"]
