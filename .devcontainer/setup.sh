#!/bin/bash

SANDBOX='sandbox'
VENV_DIR=".venv"

# 1. sandboxディレクトリを作成
if [ ! -d "$SANDBOX" ]; then
    echo "サンドボックスディレクトリを作成します。"
    mkdir -p "$SANDBOX"
    echo "サンドボックスディレクトリを $(pwd)/sandbox に作成しました。"
fi

# 2. Python仮想環境 (.venv) のセットアップと依存関係のインストール
if [ ! -d "$VENV_DIR" ]; then
    echo "--- Python仮想環境 '$VENV_DIR' を作成します ---"
    
    # 仮想環境の作成
    python3 -m venv "$VENV_DIR"
    
    # 依存関係のインストール
    echo "必要なPythonパッケージをインストールします (pandas, openpyxl, tqdm)..."
    # 仮想環境内のpipを使用してインストールを確実に行う
    "$VENV_DIR/bin/pip" install pandas openpyxl tqdm stringcase google-genai

    if [ $? -eq 0 ]; then
        echo "Python仮想環境のセットアップとパッケージのインストールが完了しました。"
    else
        echo "警告: Pythonパッケージのインストールに失敗しました。python3-venv がインストールされているか確認してください。"
    fi
else
    echo "Python仮想環境 '$VENV_DIR' は既に作成済みです。パッケージのインストールはスキップします。"
fi

# 3. .envテンプレートをサブモジュールにコピー (存在しない場合のみ)
API_ENV_TEMPLATE=".devcontainer/init/.env.api.dev"
SCREEN_ENV_TEMPLATE=".devcontainer/init/.env.screen.dev"
GEMINI_KEY=".devcontainer/init/api.ini"

API_ENV_DEST="api/.env"
SCREEN_ENV_DEST="screen/.env"
GEMINI_KEY_DEST="prompts/gemini_script/api.ini"

API_NODE_MODULES="api/scms-backend/node_modules"
SCREEN_NODE_MODULES="screen/scms-frontend/node_modules"

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

# APIのnode_modulesディレクトリを作成
if [ -d "$API_NODE_MODULES" ]; then
    echo "APIのnode_modulesディレクトリを更新します。"
    sudo rm -rf "$API_NODE_MODULES"
fi

cd api/scms-backend
echo "APIの依存関係をインストールします。"
sudo npm install
cd /workspaces

# 画面向けの .env ファイルをコピー
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

# 画面のnode_modulesディレクトリを作成
if [ -d "$SCREEN_NODE_MODULES" ]; then
    echo "画面のnode_modulesディレクトリを更新します。"
    sudo rm -rf "$SCREEN_NODE_MODULES"
fi

cd screen/scms-frontend
echo "画面の依存関係をインストールします。"
sudo npm install
cd /workspaces

# Gemini APIキーファイルをコピー
if [ -f "$GEMINI_KEY" ]; then
    if [ ! -f "$GEMINI_KEY_DEST" ]; then
        echo "$GEMINI_KEY を $GEMINI_KEY_DEST にコピーします。"
        cp "$GEMINI_KEY" "$GEMINI_KEY_DEST"
    else
        echo "Gemini APIキーのテンプレート $GEMINI_KEY は既に作成済みです。"
    fi
else
    echo "Gemini APIキーのテンプレート $GEMINI_KEY が見つからなかったため、処理をスキップしました。"
fi

# 4. データベースのマイグレーション
docker compose up -d
echo "DBコンテナの起動を待機します。"
DB_CONTAINER_NAME="db"
MYSQL_ROOT_PASSWORD="P@ssw0rd"
MAX_TRIES=12 # 60秒待機 (5秒 * 12回)
TRIES=0
while [ $TRIES -lt $MAX_TRIES ]; do
    if docker compose exec -T "$DB_CONTAINER_NAME" mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "SELECT 1" &> /dev/null; then
        echo "DB接続が確認されました。APIサーバーの起動を待機します。"
        break
    fi
    echo "DB起動待機中... ($TRIES/$MAX_TRIES)"
    sleep 5
    TRIES=$((TRIES + 1))
done
if [ $TRIES -eq $MAX_TRIES ]; then
    echo "エラー: データベースが指定時間内に起動しませんでした。手動でコンテナの状態を確認してください。"
    exit 1
fi

API_CONTAINER_NAME="api"
API_PORT="3000"
API_CHECK_ENDPOINT="http://localhost:$API_PORT/api/v1" # Hello worldエンドポイント

echo "APIサーバー ($API_CONTAINER_NAME) 起動待機を開始します..."

TRIES=0
MAX_TRIES=30 # 最大試行回数 (30回 x 5秒 = 150秒)

while [ $TRIES -lt $MAX_TRIES ]; do
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -m 5 "$API_CHECK_ENDPOINT" 2>/dev/null)

    if [ "$HTTP_CODE" = "200" ]; then
        echo "APIサーバーのヘルスチェックが成功しました (HTTP 200)。マイグレーションに進みます。"
        break
    fi

    echo "APIサーバー起動待機中... (HTTPコード: $HTTP_CODE) ($TRIES/$MAX_TRIES)"
    sleep 5
    TRIES=$((TRIES + 1))
done

if [ $TRIES -eq $MAX_TRIES ]; then
    echo "エラー: APIサーバーが指定時間内に起動しませんでした。手動でコンテナの状態を確認してください。"
    exit 1
fi

cd api/scms-backend
echo "Prisma マイグレーションを実行します。"
npm run db:migrate
echo "初期データ投入バッチを実行します。"
npm run batch:init
cd /workspaces

# エンドメッセージ
echo ""
echo "========================================================"
echo "セットアップが完了しました。"
echo ""

# 仮想環境が作成されている場合、有効化を促す
if [ -d "$VENV_DIR" ]; then
    echo "Python仮想環境をコマンド上から使う場合、以下のコマンドで仮想環境を有効化してください:"
    echo "source .venv/bin/activate"
fi

echo "========================================================"