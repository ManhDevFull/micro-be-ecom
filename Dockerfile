# ======================
# 1️⃣ Build stage
# ======================
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

# Copy project files
COPY ./dotnet ./dotnet
COPY ./chat ./chat

# Build dotnet service
WORKDIR /src/dotnet
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

# Copy built files
COPY --from=build /app/dotnet ./dotnet
COPY --from=build /app/chat ./chat

# Install supervisor (chạy nhiều tiến trình)
RUN apt-get update && apt-get install -y supervisor && apt-get clean

# Copy file cấu hình supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Expose các cổng REST + gRPC + SignalR
EXPOSE 5000 5100 5295 5296

# Chạy cả hai project song song
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
