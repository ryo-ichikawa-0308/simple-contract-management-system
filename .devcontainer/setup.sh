#!/bin/bash

SANDBOX='sandbox'

# 1. sandboxディレクトリを作成
if [ ! -d "$SANDBOX" ]; then
    echo "サンドボックスディレクトリを作成します。"
    mkdir -p sandbox
    echo "サンドボックスディレクトリを $(pwd)/sandbox に作成しました。"
fi

# 2. .envテンプレートをサブモジュールにコピー (存在しない場合のみ)
API_ENV_TEMPLATE=".devcontainer/.env.api.dev"
SCREEN_ENV_TEMPLATE=".devcontainer/.env.screen.dev"

API_ENV_DEST="api/.env"
SCREEN_ENV_DEST="screen/.env"

# API向けの .env ファイルをコピー
if [ -f "$API_ENV_TEMPLATE" ]; then
    if [ ! -f "$API_ENV_DEST" ]; then
        echo "$API_ENV_TEMPLATE を $API_ENV_DEST にコピーします。"
        cp "$API_ENV_TEMPLATE" "$API_ENV_DEST"
    else
        echo "API向けの $API_ENV_DEST は既に作成済みです。"
    fi
else
    echo "テンプレートファイル $API_ENV_TEMPLATE が見つからなかったため、処理をスキップしました。"
fi

# screen向けの .env ファイルをコピー
if [ -f "$SCREEN_ENV_TEMPLATE" ]; then
    if [ ! -f "$SCREEN_ENV_DEST" ]; then
        echo "$SCREEN_ENV_TEMPLATE を $SCREEN_ENV_DEST にコピーします。"
        cp "$SCREEN_ENV_TEMPLATE" "$SCREEN_ENV_DEST"
    else
        echo "画面向けの $SCREEN_ENV_DEST は既に作成済みです。"
    fi
else
    echo "テンプレートファイル $SCREEN_ENV_TEMPLATE が見つからなかったため、処理をスキップしました。"
fi

echo "セットアップが完了しました。"