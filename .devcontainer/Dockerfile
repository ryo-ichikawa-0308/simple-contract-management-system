FROM mcr.microsoft.com/devcontainers/typescript-node:20

# 必要なOSパッケージのインストール
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
    # MySQL
    default-mysql-client \
    # Python
    python3 \
    python3-pip \
    python3-venv \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# ユーザー設定
USER node