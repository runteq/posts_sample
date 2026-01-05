# BookShelf - おすすめ書籍共有サービス

おすすめの書籍を投稿し、いいねやコメントで交流できるWebアプリケーションです。

## 技術スタック

| カテゴリ | 技術 |
|----------|------|
| Backend | Ruby on Rails 7.1 |
| Database | PostgreSQL |
| CSS | Tailwind CSS |
| 認証 | has_secure_password（自前実装） |
| 画像 | Active Storage + Cloudinary |
| 開発環境 | Docker Compose |
| 本番環境 | Render + Neon + Cloudinary |

## 機能一覧

- ユーザー登録・ログイン・ログアウト
- 書籍投稿（タイトル、著者、おすすめポイント、画像）
- いいね機能（非同期）
- コメント機能（非同期）

---

# ローカル開発環境のセットアップ

## 必要なもの

- Docker Desktop
- Git

## セットアップ手順

### 1. リポジトリをクローン

```bash
git clone git@github.com:runteq/posts_sample.git
cd posts_sample
```

### 2. Dockerコンテナを起動

```bash
docker compose up
```

初回起動時はイメージのビルドに数分かかります。

### 3. データベースを作成

別のターミナルを開いて実行：

```bash
docker compose run --rm web rails db:create db:migrate
```

### 4. ブラウザでアクセス

http://localhost:3000

---

## よく使うコマンド

### コンテナ操作

```bash
# 起動（フォアグラウンド）
docker compose up

# 起動（バックグラウンド）
docker compose up -d

# 停止
docker compose down

# ログ確認
docker compose logs -f web
```

### Rails コマンド

```bash
# コンソール
docker compose run --rm web rails console

# マイグレーション
docker compose run --rm web rails db:migrate

# DBリセット
docker compose run --rm web rails db:reset

# ルート確認
docker compose run --rm web rails routes
```

### Gemを追加した場合

```bash
docker compose build
docker compose up
```

---

# 本番デプロイ（無料）

以下の無料サービスを使用します：

| サービス | 用途 | 無料枠 |
|----------|------|--------|
| [Render](https://render.com) | アプリホスティング | 750時間/月 |
| [Neon](https://neon.tech) | PostgreSQL | 0.5GB |
| [Cloudinary](https://cloudinary.com) | 画像ストレージ | 25GB |

---

## Step 1: Neon（データベース）

### 1-1. アカウント作成

1. https://neon.tech にアクセス
2. 「Sign Up」→ GitHubまたはGoogleでサインアップ

### 1-2. プロジェクト作成

1. 「Create a project」をクリック
2. 設定：
   - **Project name**: `bookshelf`
   - **Region**: `Asia Pacific (Singapore)`
3. 「Create project」をクリック

### 1-3. 接続文字列を取得

ダッシュボードの「Connection Details」から「Connection string」をコピー：

```
postgresql://username:password@ep-xxx.ap-southeast-1.aws.neon.tech/neondb?sslmode=require
```

> ⚠️ この文字列は後で `DATABASE_URL` として使用します

---

## Step 2: Cloudinary（画像ストレージ）

### 2-1. アカウント作成

1. https://cloudinary.com にアクセス
2. 「Sign up for free」からアカウント作成

### 2-2. API情報を取得

1. ダッシュボードにログイン
2. 画面上部の「API Environment variable」をコピー：

```
cloudinary://123456789012345:abcdefghijk@cloud_name
```

> ⚠️ この文字列は後で `CLOUDINARY_URL` として使用します

---

## Step 3: Render（アプリホスティング）

### 3-1. アカウント作成

1. https://render.com にアクセス
2. GitHubアカウントでサインアップ

### 3-2. Web Service作成

1. ダッシュボードで「New +」→「Web Service」
2. 「Build and deploy from a Git repository」を選択
3. GitHubリポジトリ `posts_sample` を選択
4. 以下を設定：

| 項目 | 値 |
|------|-----|
| **Name** | `bookshelf`（任意） |
| **Region** | `Singapore (Southeast Asia)` |
| **Branch** | `main` |
| **Runtime** | `Ruby` |
| **Build Command** | `./bin/render-build.sh` |
| **Start Command** | `bundle exec puma -C config/puma.rb` |
| **Instance Type** | `Free` |

### 3-3. 環境変数を設定

「Environment」セクションで「Add Environment Variable」をクリックし、以下を追加：

| Key | Value |
|-----|-------|
| `DATABASE_URL` | Step 1で取得したNeonの接続文字列 |
| `RAILS_MASTER_KEY` | 下記コマンドで取得した値 |
| `CLOUDINARY_URL` | Step 2で取得したCloudinaryの接続文字列 |

**RAILS_MASTER_KEY の取得方法：**

```bash
cat config/master.key
```

### 3-4. デプロイ

「Create Web Service」をクリック

初回デプロイには5〜10分かかります。完了後、発行されたURL（`https://bookshelf-xxxx.onrender.com`）にアクセスできます。

---

# コピペ用ファイル

## docker-compose.yml

```yaml
services:
  db:
    image: postgres:15
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: password
    volumes:
      - postgres_data:/var/lib/postgresql/data

  web:
    build: .
    command: bash -c "rm -f tmp/pids/server.pid && bundle exec rails server -b '0.0.0.0'"
    volumes:
      - .:/app
      - bundle_data:/usr/local/bundle
    ports:
      - "3000:3000"
    depends_on:
      - db
    environment:
      DATABASE_URL: postgres://postgres:password@db:5432
      RAILS_ENV: development
    tty: true
    stdin_open: true

volumes:
  postgres_data:
  bundle_data:
```

## Dockerfile

```dockerfile
FROM ruby:3.2.2

RUN apt-get update -qq && apt-get install -y \
    nodejs \
    npm \
    postgresql-client \
    && npm install -g yarn

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]
```

## entrypoint.sh

```bash
#!/bin/bash
set -e

rm -f /app/tmp/pids/server.pid

exec "$@"
```

## bin/render-build.sh

```bash
#!/usr/bin/env bash
set -o errexit

bundle install
bundle exec rails assets:precompile
bundle exec rails assets:clean
bundle exec rails db:migrate
```

## config/database.yml（本番用部分）

```yaml
production:
  <<: *default
  url: <%= ENV["DATABASE_URL"] %>
```

## config/storage.yml（Cloudinary設定）

```yaml
cloudinary:
  service: Cloudinary
  folder: <%= Rails.env %>
```

## render.yaml

```yaml
services:
  - type: web
    name: bookshelf
    runtime: ruby
    buildCommand: "./bin/render-build.sh"
    startCommand: "bundle exec puma -C config/puma.rb"
    envVars:
      - key: DATABASE_URL
        sync: false
      - key: RAILS_MASTER_KEY
        sync: false
      - key: CLOUDINARY_URL
        sync: false
```

---

# トラブルシューティング

## ローカル環境

### ポート3000が使用中

```bash
# 使用中のプロセスを確認
lsof -i :3000

# プロセスを終了
kill -9 <PID>
```

### DBに接続できない

```bash
# コンテナを再起動
docker compose down
docker compose up
```

### Gemが見つからない

```bash
docker compose build
docker compose up
```

---

## 本番環境

### デプロイが失敗する

Renderのログを確認：
```
Dashboard → サービス名 → Logs
```

よくある原因：
- `DATABASE_URL` が間違っている
- `RAILS_MASTER_KEY` が設定されていない
- `CLOUDINARY_URL` のフォーマットが間違っている

### 画像がアップロードできない

1. Cloudinaryダッシュボードで使用量を確認
2. `CLOUDINARY_URL` が正しく設定されているか確認

### データベース接続エラー

1. Neonのダッシュボードでプロジェクトがアクティブか確認
2. 接続文字列に `?sslmode=require` が含まれているか確認

### アプリがスリープする

Renderの無料プランでは15分間アクセスがないとスリープします。
初回アクセス時に起動まで30秒〜1分かかることがあります。

---

# 環境変数一覧

| 変数名 | 用途 | 設定場所 |
|--------|------|----------|
| `DATABASE_URL` | PostgreSQL接続 | Render |
| `RAILS_MASTER_KEY` | credentials復号 | Render |
| `CLOUDINARY_URL` | 画像ストレージ | Render |
| `RAILS_ENV` | 環境指定 | 自動設定 |

---

## ライセンス

MIT
