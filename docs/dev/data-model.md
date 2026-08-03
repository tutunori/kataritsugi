# データモデル

ステータス: **方針ドラフト**（論理モデル。物理スキーマは実装時に遷移）

## 1. ER 概要

```text
Account (契約者)
  │ 1
  │
  ├──◄ UserMembership ►── User (ログイン主体。契約者と同一のことも)
  │
  ├── plan / entitlements
  │
  ├──◄ Subject (話者) 1..n
  │      │
  │      ├──◄ Consent
  │      ├──◄ InterviewSession 1..n
  │      │      ├── AudioAsset 1..n
  │      │      ├── Transcript 1..n
  │      │      └── MemoryTag 0..n
  │      │
  │      ├──◄ Autobiography 1..n（バージョン）
  │      └──◄ LifeProfile 0..1（premium）
  │
  └──◄ FamilyShare (招待)
```

## 2. 主要エンティティ

### Account

契約・課金の単位。

| 属性 | 説明 |
| --- | --- |
| id | UUID |
| plan | `demo` / `free` / `paid` / `premium` |
| plan_expires_at | デモ終了・サブスク期末 |
| stripe_customer_id | 任意 |
| created_at | |

### User

ログインする人。

| 属性 | 説明 |
| --- | --- |
| id | |
| email | |
| password_digest / IdP sub | |
| display_name | |
| role_on_account | `owner` / `editor` / `viewer` |

### Subject（話者）

インタビュー対象。契約者の親など。

| 属性 | 説明 |
| --- | --- |
| id | |
| account_id | |
| display_name | |
| birth_date | 任意（時系列整理用） |
| relation_label | 例: 父、母 |
| notes | 家族だけが見るメモ |
| status | `active` / `archived` |

### Consent

用途別同意。

| 属性 | 説明 |
| --- | --- |
| subject_id | |
| purpose | `autobiography` / `family_share` / `dialogue_profile` / `voice_likeness` / `welfare_export` |
| granted | bool |
| granted_by | user_id または subject 代理 |
| granted_at | |
| revoked_at | 任意 |
| document_version | 同意文面の版 |

### InterviewSession

1 回のインタビュー。

| 属性 | 説明 |
| --- | --- |
| id | |
| subject_id | |
| conducted_by | user_id |
| started_at / ended_at | |
| guide_id | 使用した質問セット |
| status | `recording` / `uploading` / `transcribing` / `ready` / `failed` |
| duration_sec | |
| client_device_id | 任意 |

### AudioAsset

| 属性 | 説明 |
| --- | --- |
| id | |
| session_id | |
| storage_key | Object Storage パス |
| content_type | 例: audio/m4a |
| byte_size | |
| checksum | |
| recorded_at | |
| upload_state | `pending` / `complete` |

### Transcript

| 属性 | 説明 |
| --- | --- |
| id | |
| session_id | |
| audio_asset_id | |
| engine | ASR 名と版 |
| language | `ja` など |
| raw_text | 全文 |
| segments_json | 時刻・話者ラベル付き |
| edited_text | 人手修正後 |
| status | `processing` / `ready` / `failed` |

### MemoryTag

感情・事実のラベル。

| 属性 | 説明 |
| --- | --- |
| id | |
| session_id | |
| transcript_id | 任意 |
| kind | `emotion` / `life_event` / `era` / `person` / `place` |
| label | 例: うれしい、就職、昭和30年代 |
| span_start_ms / span_end_ms | 任意 |
| confidence | AI 付与時 |
| source | `ai` / `user` |

### Autobiography

| 属性 | 説明 |
| --- | --- |
| id | |
| subject_id | |
| version | 整数 |
| title | |
| body_markdown / body_json | 章構造 |
| source_session_ids | 使用セッション |
| generated_by | `ai` / `human` / `mixed` |
| status | `draft` / `published` |
| artifact_pdf_key | 任意 |

### LifeProfile（premium）

対話・福祉向けの構造化プロファイル。

| 属性 | 説明 |
| --- | --- |
| id | |
| subject_id | |
| version | |
| profile_json | 価値観、口調、重要エピソード、禁忌トピック等 |
| consent_id | dialogue_profile 同意への参照 |
| status | `draft` / `active` / `retired` |

### Job

非同期処理。

| 属性 | 説明 |
| --- | --- |
| id | |
| type | `transcribe` / `tag` / `autobiography` / `life_profile` |
| payload | |
| priority | premium 向け |
| status | `queued` / `running` / `succeeded` / `failed` |
| error_message | 安全な範囲のみ |

### FamilyShare

| 属性 | 説明 |
| --- | --- |
| account_id | |
| invite_email | |
| role | `editor` / `viewer` |
| status | `pending` / `accepted` / `revoked` |

## 3. entitlements 例

`/api/v1/me` が返す例:

```json
{
  "plan": "paid",
  "entitlements": [
    "record",
    "transcribe",
    "autobiography",
    "family_share"
  ],
  "limits": {
    "subjects": 2,
    "sessions_per_month": 8,
    "max_session_minutes": 90,
    "storage_bytes": 21474836480
  }
}
```

premium では `dialogue_profile` / `priority_queue` / `premium_export` などが追加される。

## 4. インデックス・保持の方針

- `sessions(subject_id, started_at)`
- `transcripts(session_id)`
- `consents(subject_id, purpose)` UNIQUE WHERE revoked_at IS NULL
- 音声オブジェクトは論理削除後、猶予期間を経て物理削除

## 5. 関連

- フロー: `docs/dev/system-flow.md`
- プラン: `docs/product/plan-limits-and-metrics.md`
