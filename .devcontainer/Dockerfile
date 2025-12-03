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
    && rm -rf /var/lib/apt/lists/* \
    # Angularテスト環境
    && apt-get update \
    && apt-get install -y libnss3 libxss1 libasound2 \
    && apt-get install -y chromium \
    && apt-get install -y fonts-noto-cjk \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
ENV CHROME_BIN /usr/bin/chromium
# ユーザー設定
USER node