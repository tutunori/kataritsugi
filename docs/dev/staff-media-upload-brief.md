# 指示書: Staff 音声・画像アップロード（タスク 1）

対象実装者: **Windows 側 Cursor**（Android / Expo）  
サーバ: **WSL2 上の Rails**（`apps/server`。このリポジトリと同じツリー）  
方針: [step-a.md](../step-a.md)  
前提骨格: [apps/staff/](../../apps/staff/)（ログインとセッション開始まで済み）

---

## 1. ゴール

セッション開始後に、Staff アプリから次ができること。

1. **音声を録音してアップロード**（`kind=audio`）
2. **写真を撮影（またはギャラリー選択）してアップロード**（`kind=photo`）
3. （推奨）アップロード後に **セッション完了** を呼び、サーバ側ジョブを起動する

カメラ QR 読取・ASR/LLM 実接続は **本指示書の範囲外**（別タスク）。

---

## 2. 作業場所の分担

| 環境 | 役割 |
| --- | --- |
| Windows Cursor | `apps/staff` の UI・録音・撮影・multipart アップロード |
| WSL2 Cursor | Rails 起動・ログ確認・必要なら API 微修正 |

同一 Git リポジトリを、Windows からは `\\wsl$\...` や同期済みクローン経由で触る想定。  
**Staff の変更は `apps/staff` に閉じる。** Rails 変更が必要なら WSL 側に依頼／別コミット。

---

## 3. 前提（サーバ）

WSL2 で Rails と MySQL が起動していること。

```bash
# WSL2
cd /path/to/kataritsugi
docker compose up -d db
cd apps/server
bundle exec rails server -b 0.0.0.0
```

`-b 0.0.0.0` が重要。Windows / 実機から WSL の Rails に届けるため。

シードユーザ: `demo@example.com` / `password123`

### 3.1 API_BASE（Windows → WSL）

`apps/staff/App.tsx` の `API_BASE` を環境に合わせる。

| 実行場所 | 目安 |
| --- | --- |
| Android エミュレータ → ホストの WSL | エミュレータの `10.0.2.2` は **Windows ホスト**向け。WSL の Rails には届かないことが多い |
| 実機 / エミュレータ → WSL | WSL の IP（例: `hostname -I` の先頭）: `http://<WSL_IP>:3000` |
| Windows 上のブラウザ確認 | 同様に WSL IP、または `localhost` がポートフォワードされている場合のみ |

接続確認: `GET {API_BASE}/api/v1/status` → `{ "ok": true, "service": "kataritsugi", "step": "A" }`

---

## 4. 既存 API（変更不要・この契約に合わせる）

認証: すべて `Authorization: Bearer <token>`（ログインで取得済み）。

### 4.1 セッション開始（既存）

`POST /api/v1/recording_sessions`  
Body JSON: `{ "qr_token": "<user.qr_token>" }`  
STEP A では **ログイン中 User 自身の qr_token のみ** 可。

応答例:

```json
{ "ok": true, "recording_session": { "id": 1, "status": "open", ... } }
```

以降、返ってきた `id` をセッション ID として保持する。

### 4.2 メディアアップロード（本タスクの中心）

`POST /api/v1/recording_sessions/:recording_session_id/media_assets`

- **Content-Type**: `multipart/form-data`（JSON ではない）
- フィールド:
  - `kind` … `"audio"` または `"photo"`
  - `file` … バイナリ（Rails `params[:file]` / ActiveStorage）

応答例:

```json
{ "ok": true, "media_asset": { "id": 1, "kind": "audio", "recording_session_id": 1, "attached": true } }
```

エラー:

| 状況 | error |
| --- | --- |
| kind 不正 | `invalid_kind` |
| file なし | `file_required` |
| 未ログイン | `unauthorized` |

### 4.3 セッション完了（推奨で呼ぶ）

`POST /api/v1/recording_sessions/:id/complete`  
Body なしで可。文字起こしジョブを起動（現状スタブ）。

### 4.4 確認用

`GET /api/v1/recording_sessions/:id`  
→ `media_assets` / `transcript` を含む。

---

## 5. 実装要件（Staff）

### 5.1 依存パッケージ（Expo）

必要に応じて追加（バージョンは Expo SDK に合わせる）:

- 録音: `expo-av` または `expo-audio`（SDK に合う方）
- 写真: `expo-image-picker`（撮影＋ライブラリ）
- （任意）権限説明: `expo-image-picker` / AV の permission API

`app.json` に Android のマイク・カメラ権限が必要なら追記する。

### 5.2 UI フロー（最小）

ログイン済みかつセッション ID がある状態で:

1. **録音開始 / 停止** → 停止後に `kind=audio` でアップロード
2. **写真を撮る / 選ぶ** → `kind=photo` でアップロード
3. **完了** ボタン → `complete` API
4. 画面上の `log` に成功・失敗を出す（既存パターン踏襲）

状態として少なくとも保持:

- `token`
- `sessionId`（開始後）
- アップロード件数 or 直近の media_asset id

### 5.3 multipart 送信の注意

`fetch` + `FormData` を使う。

- `Authorization` ヘッダは付ける
- **`Content-Type: multipart/form-data` を手で付けない**（boundary 欠落の原因になる。FormData に任せる）
- React Native の file パートはおおむね次の形:

```ts
formData.append('kind', 'audio')
formData.append('file', {
  uri: localUri,
  name: 'recording.m4a',
  type: 'audio/mp4' // 実ファイルに合わせる
} as any)
```

写真例: `name: 'photo.jpg'`, `type: 'image/jpeg'`

### 5.4 音声フォーマット

STEP A では次のどちらかでよい（サーバは ActiveStorage で受け取りのみ）:

- m4a / mp4 (AAC)
- 端末が出しやすい形式

長時間分割は不要。おおよそ **数分〜10 分想定の単発**。

---

## 6. 受け入れ条件（Done）

- [ ] Windows 上の Staff から WSL の Rails にログインできる
- [ ] セッション開始後、音声 1 件以上が `media_assets` に付き、`attached: true`
- [ ] 写真 1 件以上も同様
- [ ] `complete` 後、`GET .../recording_sessions/:id` で assets が見える（transcript はスタブで可）
- [ ] 失敗時に画面 log に理由が出る（ネットワーク / API error）
- [ ] Rails 側の大きな仕様変更なし（契約どおり multipart）

Admin または `rails runner` での確認例（WSL）:

```bash
cd apps/server
bundle exec rails runner 's=RecordingSession.last; puts s.media_assets.map{|a| [a.id,a.kind,a.file.attached?].inspect }'
```

---

## 7. やらないこと（本タスク）

- カメラでの QR スキャン（タスク 2）
- ASR / LLM の本番接続（タスク 3・Rails）
- オフラインキューの本格実装
- APK 自動更新
- UI の本デザイン（動く最低限でよい）

---

## 8. 詰まったときの切り分け

1. `GET /api/v1/status` が Windows / 端末から見えるか（API_BASE）
2. ログインで token が取れるか
3. セッション create の応答 id があるか
4. multipart を curl で直接試す（WSL から）:

```bash
TOKEN=...
SID=1
curl -s -X POST "http://127.0.0.1:3000/api/v1/recording_sessions/${SID}/media_assets" \
  -H "Authorization: Bearer ${TOKEN}" \
  -F "kind=photo" \
  -F "file=@/path/to/sample.jpg"
```

Staff だけ失敗するなら FormData / URI / MIME を疑う。curl も失敗なら Rails ログ（WSL）を見る。

---

## 9. 完了時

- `apps/staff` の変更をコミット（メッセージ例: `feat(staff): セッションへの音声・画像アップロードを追加`）
- 本指示書の受け入れチェックを埋め、必要なら [setup-step-a.md](setup-step-a.md) の「まだ未実装」から当該項目を更新
