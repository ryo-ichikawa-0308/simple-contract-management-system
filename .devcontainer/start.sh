#!/bin/bash

RUNNING_COUNT=$(docker ps | grep scms | wc -l)
REQUIRED_COUNT=3

if [ "$RUNNING_COUNT" -lt "$REQUIRED_COUNT" ]; then
    echo "DBサーバ、APサーバ、APIサーバのコンテナを起動します。"
    docker compose up -d
    echo "コンテナを起動しました。"
else
    echo "DBサーバ、APサーバ、APIサーバの各コンテナは起動済みです。"
fi