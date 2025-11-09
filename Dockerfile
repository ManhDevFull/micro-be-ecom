# ---------- Build phase ----------
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build

WORKDIR /src

# Copy tất cả project
COPY ./dotnet ./dotnet
COPY ./chat ./chat
COPY ./Contracts ./Contracts

# Restore cho từng project
RUN dotnet restore ./dotnet/dotnet.csproj
RUN dotnet restore ./chat/chat.csproj

# Build release cho cả 2
RUN dotnet publish ./dotnet/dotnet.csproj -c Release -o /app/dotnet
RUN dotnet publish ./chat/chat.csproj -c Release -o /app/chat


# ---------- Runtime phase ----------
FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS runtime

WORKDIR /app

# Copy 2 app đã build
COPY --from=build /app/dotnet ./dotnet
COPY --from=build /app/chat ./chat

# Cài thêm process manager (để chạy 2 app song song)
RUN apt-get update && apt-get install -y supervisor

# Tạo file cấu hình cho supervisor
RUN mkdir -p /etc/supervisor/conf.d
COPY ./supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 5000 5001
ENTRYPOINT ["supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
