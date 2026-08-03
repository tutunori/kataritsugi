# システム基本フロー

ステータス: **方針ドラフト**

## 1. エンドツーエンド概要

```text
契約者登録
  → 話者作成 + 同意取得
    → インタビュー実施（録音）
      → アップロード
        → 文字起こし
          → タグ付け（感情・事実）
            → （複数回繰り返し）
              → 自叙伝ドラフト生成
                → 人手編集・確定
                  → （premium）ライフプロファイル / 対話
```

## 2. フロー詳細

### F1. オンボーディング

```text
[開始] アプリインストール
  → アカウント作成（demo 開始）
  → 利用目的の説明（自叙伝が一次、対話は任意）
  → 話者プロファイル入力（名前・続柄・生年など任意）
  → 自叙伝作成の同意（話者または代理）
  → チュートリアル: 「最初の 15 分だけ録ってみましょう」
[完了] ホームに話者と「インタビュー開始」が表示
```

 entlements 不足時はアップグレード導線を出す。

### F2. インタビュー録音

```text
[開始] インタビュー開始
  → ガイド質問を 1 問表示（大きく・読み上げ可）
  → 録音開始（端末ローカルに逐次保存）
  → 一時停止 / 再開 / 終了
  → 終了確認「アップロードして文字にしますか？」
  → 通信可: 署名 URL 取得 → PUT → 完了通知
  → 通信不可: 送信キューに残し、復帰後に自動送信
[完了] セッション status = transcribing
```

失敗時: ローカルに残し、再送ボタンを出す。録音消失を最優先で防ぐ。

### F3. 文字起こし

```text
[開始] アップロード完了イベント
  → Job(type=transcribe) をキューへ（premium は priority 高）
  → Worker が音声取得 → ASR
  → Transcript 保存（segments + raw_text）
  → （任意）Job(type=tag) で MemoryTag 案を生成
  → プッシュ / ポーリングでモバイルへ通知
[完了] 契約者がテキストを確認・修正
```

### F4. 自叙伝生成

```text
[開始] 「自叙伝を作る」（paid 以上。demo は透かし付き限定）
  → 対象セッションを選択（デフォルト: 未使用分すべて）
  → Job(type=autobiography)
  → LLM が章立てドラフト生成
  → Autobiography(version=n, status=draft) 保存
  → 編集画面で修正
  → 公開（published）または PDF 生成
[完了] 家族 viewer にも共有（権限があれば）
```

### F5. プレミアム: ライフプロファイルと対話

```text
[前提] plan=premium かつ consent(dialogue_profile)=true
  → Job(type=life_profile)
  → LifeProfile 生成
  → 対話 UI で質問
  → 応答は profile + autobiography + 関連 transcript を根拠に生成
  → 根拠セッションへのリンクを表示
```

根拠がない内容は生成を抑制するか、不確実であることを明示する。

### F6. プラン変更・上限到達

```text
操作（録音・生成など）
  → サーバが limits を検査
  → OK: 実行
  → NG: 403 + 理由コード（sessions_exhausted 等）
  → クライアントがアップグレード画面へ
```

超過後も閲覧・編集・エクスポートは維持（`docs/product/plan-limits-and-metrics.md`）。

### F7. 削除・撤回

```text
削除依頼（話者単位 or アカウント単位）
  → 同意撤回の記録
  → 対話プロファイルの停止
  → 音声・テキスト・成果物の削除ジョブ
  → 完了通知（猶予期間があれば明記）
```

## 3. 状態遷移（InterviewSession）

```text
recording → uploading → transcribing → ready
                │             │
                └──── failed ◄┘
```

`ready` 後も再文字起こしで `transcribing` に戻せる（プランによる）。

## 4. シーケンス（録音〜文字起こし）

```text
Mobile          API           Storage         Worker         ASR
  │              │               │              │             │
  │ create session│               │              │             │
  │─────────────▶│               │              │             │
  │ signed URL   │               │              │             │
  │◀─────────────│               │              │             │
  │ PUT audio    │               │              │             │
  │─────────────────────────────▶│              │             │
  │ complete     │               │              │             │
  │─────────────▶│ enqueue job   │              │             │
  │              │─────────────────────────────▶│             │
  │              │               │  get audio   │             │
  │              │               │◀─────────────│             │
  │              │               │              │ transcribe  │
  │              │               │              │────────────▶│
  │              │               │              │◀────────────│
  │              │ save transcript│              │             │
  │              │◀─────────────────────────────│             │
  │ poll/push    │               │              │             │
  │◀─────────────│               │              │             │
```

## 5. 関連

- UI: `docs/design/ui-overview.md`
- データモデル: `docs/dev/data-model.md`
- アーキテクチャ: `docs/dev/architecture.md`
