# ======================
# 1️⃣ Build stage
# ======================
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

# Copy riêng từng project (Render thường dùng context repo root)
COPY dotnet/ ./dotnet/
COPY chat/ ./chat/
COPY Contracts/ ./Contracts/

# Build dotnet service
WORKDIR /src/dotnet
RUN ls -la && find . -maxdepth 2 && echo "=== END LS ==="
RUN dotnet restore dotnet.csproj
RUN dotnet publish dotnet.csproj -c Release -o /app/dotnet

# Build chat service
WORKDIR /src/chat
RUN dotnet restore chat.csproj
RUN dotnet publish chat.csproj -c Release -o /app/chat


# ======================
# 2️⃣ Runtime stage
# ======================
FROM mcr.microsoft.com/dotnet/aspnet:9.0
WORKDIR /app

# Copy các output đã build
COPY --from=build /app/dotnet ./dotnet
COPY --from=build /app/chat ./chat

# Cài supervisor để chạy song song
RUN apt-get update && apt-get install -y supervisor && apt-get clean

# Copy file cấu hình supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Expose các port REST + gRPC + SignalR
EXPOSE 5000 5100 5295 5296

# Chạy 2 service song song
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
