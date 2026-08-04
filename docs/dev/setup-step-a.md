# STEP A 開発セットアップ

対象: Rails（`apps/server`）＋ Expo Staff（`apps/staff`）。方針は [step-a.md](../step-a.md)。

## 前提

- Ruby 3.4+（Rails 8.1）
- MySQL 8（下記 Docker Compose で可）
- Node.js（Staff 用。`npm` / Expo）

## MySQL

```bash
# リポジトリルート
docker compose up -d db
```

| 項目 | 値 |
| --- | --- |
| host | 127.0.0.1:**3307**（compose。3306 が他用途の場合の既定） |
| user / password | kataritsugi / secret |
| DB | kataritsugi_development / kataritsugi_test |

環境変数で上書き可: `DB_HOST` / `DB_PORT` / `DB_USERNAME` / `DB_PASSWORD`。

## Rails

```bash
cd apps/server
bundle install
bin/rails db:prepare db:seed
bin/rails server
```

| URL | 内容 |
| --- | --- |
| `/` | トップ |
| `/register` `/login` `/mypage` | User Web |
| `/admin` | Admin（User と別認証） |
| `/api/v1/*` | Android 向け API |
| `/downloads/android` | APK 置き場（`storage/downloads/android-latest.apk`） |

シード: `demo@example.com` / `admin@example.com`（どちらも `password123`）。

### 主な API

| メソッド | パス | 内容 |
| --- | --- | --- |
| POST | `/api/v1/auth/login` | `{ email, password, device_id }` → token |
| GET/PATCH | `/api/v1/me` | プロファイル（basic_info） |
| POST | `/api/v1/recording_sessions` | `{ qr_token }` でセッション開始 |
| POST | `/api/v1/recording_sessions/:id/media_assets` | `kind` + `file` |
| POST | `/api/v1/recording_sessions/:id/complete` | 文字起こし〜補正ジョブ |
| POST | `/api/v1/memoirs` | 回顧録 PDF 生成 |

文字起こし・AI 補正・PDF は **スタブ実装**（後で ASR / LLM に差し替え）。

## Staff（Expo）

```bash
cd apps/staff
npm install
npx expo start
```

`App.tsx` の `API_BASE` を環境に合わせて変更する（エミュレータ既定は `http://10.0.2.2:3000`）。

## まだ未実装（次タスク）

- 実 ASR / LLM 接続
- Android での音声・画像撮影アップロード
- カメラによる QR 読取
- APK 自動更新フィード（tanagrid 同型の本実装）
