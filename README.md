# 語り継ぎ（Kataritsugi）

高齢の話者へのインタビュー音声から、感情と事実を残し、自叙伝としてまとめるライフヒストリーサービス。

現在は **STEP A**（簡易稼働プロトタイプ）の実装中。

## ドキュメント

→ **[docs/readme.md](docs/readme.md)**（STEP A / B / C と企画ドキュメント）

## リポジトリ構成

```text
kataritsugi/
├─ apps/
│  ├─ server/   # Rails（API・マイページ・Admin）
│  └─ staff/    # Expo Android（職員用・骨格）
├─ compose.yml  # 開発用 MySQL
└─ docs/
```

## 開発の始め方（STEP A）

```bash
# MySQL（ホスト 3307。他の MySQL と共存用）
docker compose up -d db

# サーバ
cd apps/server
bundle install
bin/rails db:prepare db:seed
bin/rails server
```

シード:

| 種別 | メール | パスワード |
| --- | --- | --- |
| User | demo@example.com | password123 |
| Admin | admin@example.com | password123 |

- マイページ: http://localhost:3000/mypage  
- Admin: http://localhost:3000/admin  
- API: `GET /api/v1/status`

Staff アプリは [apps/staff/README.md](apps/staff/README.md)。

詳細手順は [docs/dev/setup-step-a.md](docs/dev/setup-step-a.md)。
