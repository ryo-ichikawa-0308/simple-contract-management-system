# simple-contract-management-system

ユーザー、サービス、契約テーブルを持つシステムのサンプル

## 概要

シンプルなDBとAPI、画面を持つシステムのサンプルです。本プロジェクトは、システム設計、ガバナンス設計、構築等の学習及び著者の技術スタック棚卸しのために作成したもので、複数のコンポーネントを**Gitサブモジュール**として連携させる形で作成されています。

本プロジェクト(及びそのサブモジュール)は、厳密なドキュメント統制と、CI工程にAIレビューを組み込むことによる、DevOpsの向上を企図して設計されています。

## プロジェクト構成

すべてのコンポーネントは独立したリポジトリとしてGitサブモジュールで管理されています。

- **simple-contract-management-system** (Main Repository) メインプロジェクト。開発コンテナの定義やプロジェクト全体の設定・統括に必要なファイル
- **db-docs** (Git Submodule) データベース定義書及び、Prismaコード自動生成プログラム
- **api-docs** (Git Submodule) 画面からのエンドポイントになるAPIの設計書
- **api** (Git Submodule) API設計書に基づいて実装したAPIのコード
- **screen** (Git Submodule) 画面のコード
- **prompts** (Git Submodule) AIガバナンスとして用いた、あるいはコード生成に用いたプロンプト
- **sandbox** AIあるいはスクリプトによる自動生成結果を格納する(開発コンテナインストール時に自動生成。Git管理対象外)

## プロジェクトダウンロード方法

本プロジェクトのダウンロードと開発環境のセットアップには、**WSL**、**VS Code**、および**Docker**が必要です。

### 1. メインプロジェクトのクローン

WSLまたはLinuxターミナルで本プロジェクトをクローンしてください。

```bash
git clone --recurse-submodules https://github.com/ryo-ichikawa-0308/simple-contract-management-system.git
```

**ヒント:** `--recurse-submodules`オプションにより、サブモジュールも同時にクローンされます。もしこのオプションを忘れた場合は、`git submodule update --init --recursive`を別途実行してください。

### 2. 開発コンテナの起動

クローン後、VS Codeで本プロジェクトを開くと、自動的に開発コンテナのビルドと起動が促されます。

```bash
cd simple-contract-management-system
code .
```

- **初回起動時**にDocker Composeによるビルドが行われ、Node.js、Python、MySQLクライアントが組み込まれた開発環境がセットアップされます。
- コンテナが起動したら、VS Code左下の「開発コンテナー」という表示を確認してください。

### 3. (オプション) サブモジュールの手動更新

万が一、サブモジュールのコンテンツが不足している場合は、コンテナ内のターミナルで以下のコマンドを実行してください。

```bash
git submodule update --init --recursive
```

## その他

本プロジェクト及びサブモジュール内でサンプルデータとして使用している固有名詞は、それぞれ下記の手順で作成した架空のものです。

- 企業名、人名、住所、サービス名等の固有名詞: すべてAIで自動生成
- メールアドレス: すべて`username@example.com`のような形式でAIで自動生成
- 電話番号: すべて[総務省 電気通信番号指定状況](https://www.soumu.go.jp/main_sosiki/joho_tsusin/top/tel_number/number_shitei.html)を参照し、未割り当ての番号領域(例：0900-xxx-xxxx、0800-xxx-xxxxなど)を利用してAIで自動生成
- エラーコード等、システム固有の識別符号: すべてAIで自動生成

本プロジェクトの創作動機及び過程の説明は[こちら](./NOTICE.md)。

本プロジェクト(サブモジュール含む)は[MITライセンス](./LICENCE.md)にて公開されます。

(C)2025 Ryo ICHIKAWA
