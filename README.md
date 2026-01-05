# BookShelf - おすすめ書籍共有サービス

おすすめの書籍を投稿し、いいねやコメントで交流できるWebアプリケーションです。

## 技術スタック

- **Backend**: Ruby on Rails 7.1
- **Database**: PostgreSQL
- **CSS**: Tailwind CSS
- **認証**: has_secure_password
- **画像**: Active Storage + Cloudinary
- **開発環境**: Docker Compose

## ローカル開発

### 起動

```bash
docker compose up
```

http://localhost:3000 でアクセス

### 停止

```bash
docker compose down
```

### DBリセット

```bash
docker compose run --rm web rails db:reset
```

### コンソール

```bash
docker compose run --rm web rails console
```

---

## 本番デプロイ（無料）

以下の無料サービスを使用します：

| サービス | 用途 | 無料枠 |
|----------|------|--------|
| [Render](https://render.com) | アプリホスティング | 750時間/月 |
| [Neon](https://neon.tech) | PostgreSQL | 0.5GB |
| [Cloudinary](https://cloudinary.com) | 画像ストレージ | 25GB |

---

## 1. Neon（データベース）のセットアップ

### 1-1. アカウント作成

1. https://neon.tech にアクセス
2. GitHubまたはGoogleアカウントでサインアップ

### 1-2. プロジェクト作成

1. 「Create a project」をクリック
2. 以下を設定：
   - **Project name**: `bookshelf`
   - **Region**: `Asia Pacific (Singapore)` ※日本に近い
3. 「Create project」をクリック

### 1-3. 接続文字列を取得

1. プロジェクトのダッシュボードで「Connection Details」を確認
2. 「Connection string」をコピー（後で使用）

```
postgresql://username:password@ep-xxx.ap-southeast-1.aws.neon.tech/neondb?sslmode=require
```

---

## 2. Cloudinary（画像ストレージ）のセットアップ

### 2-1. アカウント作成

1. https://cloudinary.com にアクセス
2. 「Sign up for free」からアカウント作成

### 2-2. API情報を取得

1. ダッシュボードにログイン
2. 「Dashboard」ページの上部にある情報をメモ：
   - **Cloud Name**
   - **API Key**
   - **API Secret**
3. または「API Environment variable」をコピー

```
CLOUDINARY_URL=cloudinary://API_KEY:API_SECRET@CLOUD_NAME
```

---

## 3. Render（アプリホスティング）のセットアップ

### 3-1. 事前準備

コードをGitHubにプッシュしておく：

```bash
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/YOUR_USERNAME/bookshelf.git
git push -u origin main
```

### 3-2. RAILS_MASTER_KEYを確認

ローカルの `config/master.key` の内容をコピー（後で使用）

```bash
cat config/master.key
```

### 3-3. Renderでデプロイ

1. https://render.com にアクセス
2. GitHubアカウントでサインアップ
3. 「New +」→「Web Service」をクリック
4. GitHubリポジトリを選択
5. 以下を設定：

| 項目 | 値 |
|------|-----|
| **Name** | `bookshelf` |
| **Region** | `Singapore (Southeast Asia)` |
| **Branch** | `main` |
| **Runtime** | `Ruby` |
| **Build Command** | `./bin/render-build.sh` |
| **Start Command** | `bundle exec puma -C config/puma.rb` |

### 3-4. 環境変数を設定

「Environment」タブで以下を追加：

| Key | Value |
|-----|-------|
| `DATABASE_URL` | Neonの接続文字列 |
| `RAILS_MASTER_KEY` | `config/master.key`の内容 |
| `CLOUDINARY_URL` | Cloudinaryの接続文字列 |

### 3-5. デプロイ

「Create Web Service」をクリックしてデプロイ開始

初回デプロイには5〜10分かかります。

---

## 4. デプロイ後の確認

1. Renderのダッシュボードでデプロイ完了を確認
2. 発行されたURL（`https://bookshelf-xxxx.onrender.com`）にアクセス
3. 新規登録→ログイン→投稿ができることを確認

---

## トラブルシューティング

### デプロイが失敗する場合

Renderのログを確認：

```
Dashboard → サービス名 → Logs
```

よくある原因：
- `DATABASE_URL`が間違っている
- `RAILS_MASTER_KEY`が設定されていない
- `CLOUDINARY_URL`のフォーマットが間違っている

### 画像がアップロードできない場合

1. Cloudinaryダッシュボードで使用量を確認
2. `CLOUDINARY_URL`が正しく設定されているか確認

### データベース接続エラー

1. Neonのダッシュボードでプロジェクトがアクティブか確認
2. 接続文字列に`?sslmode=require`が含まれているか確認

---

## ライセンス

MIT
