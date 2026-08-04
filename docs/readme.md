# ドキュメント一覧

プロジェクト仮称: **語り継ぎ（Kataritsugi）**  
ライフヒストリー（自叙伝的な生涯記録）を、インタビュー音声から蓄積・編集・活用するサービス。

ファイル名は小文字ハイフン区切り。用途ごとに `product` / `design` / `dev` / `ops` / `releases` に分ける。

## アイデアメモ

| ファイル | 内容 |
| --- | --- |
| [ideas.md](ideas.md) | ランダムな着想の箇条書き置き場（未整理） |

## 段階ロードマップ（STEP A → B → C）

| STEP | 位置づけ | 主な文書 |
| --- | --- | --- |
| **A** | 簡易・実装容易な前段階（検討骨格） | [step-a.md](step-a.md) |
| **B** | 施設向け検証プロトタイプ | [prototype-facility-trial.md](prototype-facility-trial.md) |
| **C** | 本製品「語り継ぎ」 | `product/` ほか design / dev / ops |

## 試験運用・前段階（STEP A / B）

| ファイル | 内容 |
| --- | --- |
| [step-a.md](step-a.md) | STEP A。B より簡易な前段階の検討骨格 |
| [prototype-facility-trial.md](prototype-facility-trial.md) | STEP B。施設向け検証プロトタイプ（QR セッション・日記／回顧録・Rails＋Android）。料金・製品ロードマップは対象外 |

## product — 何を作るか（STEP C）

| ファイル | 内容 |
| --- | --- |
| [product/vision.md](product/vision.md) | 製品ビジョン、価値提案、成長イメージ |
| [product/personas-and-gtm.md](product/personas-and-gtm.md) | 購買ターゲット・話者ペルソナ・Go-to-Market |
| [product/roadmap.md](product/roadmap.md) | フェーズ計画、認証・課金の方針 |
| [product/plan-limits-and-metrics.md](product/plan-limits-and-metrics.md) | デモ／無料／有料／プレミアムの上限と計測指標 |
| [product/premium-value.md](product/premium-value.md) | プレミアム版の付加価値機能 |
| [product/competitive-analysis-and-service-model.md](product/competitive-analysis-and-service-model.md) | 競合8社比較と AI＋2名のモデルケース |

## design — どう見せるか

| ファイル | 内容 |
| --- | --- |
| [design/ui-overview.md](design/ui-overview.md) | 画面一覧と簡易 UI ワイヤー |

## dev — どう作るか

| ファイル | 内容 |
| --- | --- |
| [dev/setup-step-a.md](dev/setup-step-a.md) | STEP A の起動手順・API 概要 |
| [dev/architecture.md](dev/architecture.md) | システム構成、各層の責務、通信方針 |
| [dev/data-model.md](dev/data-model.md) | 主要エンティティと関係 |
| [dev/system-flow.md](dev/system-flow.md) | 基本業務フロー（録音〜自叙伝生成） |
| [dev/mobile-app.md](dev/mobile-app.md) | モバイルアプリ（録音・文字起こし）方針 |

## ops — どう運用するか

| ファイル | 内容 |
| --- | --- |
| [ops/deploy.md](ops/deploy.md) | 本番デプロイ方針（概要） |
| [ops/admin.md](ops/admin.md) | 管理画面の方針 |

## releases — 公開記録

| ファイル | 内容 |
| --- | --- |
| [releases/readme.md](releases/readme.md) | 版ごとの記録の残し方 |

## 置き場所の指針

- 段階（STEP A / B）の検討・試験 → ルート直下の `step-a.md` / `prototype-facility-trial.md`
- 未整理の着想 → `ideas.md`
- 製品判断・仕様の方針（STEP C） → `product/`
- 画面・体験の骨格 → `design/`
- コードを書く人向け → `dev/`
- 動かす／配る人向け → `ops/`
- 公開済みの版の控え → `releases/`

## 関連ステータス

本書一式は **企画ドラフト**。実装前の合意形成用であり、数値・価格・技術選定は今後の検証で更新する。
