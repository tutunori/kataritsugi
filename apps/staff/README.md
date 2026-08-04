# STEP A Staff アプリ（Expo）

ログインと「自分の QR トークンでのセッション開始」までの骨格。  
音声・画像収集とカメラ QR 読取は次の実装で追加する。

## 起動

```bash
# 別ターミナルで Rails
cd apps/server && bin/rails server

# Staff
cd apps/staff
npm install
npx expo start
```

エミュレータからホストの Rails へは `App.tsx` の `API_BASE`（既定 `http://10.0.2.2:3000`）を使う。  
実機の場合は PC の LAN IP に変更する。

シードユーザ: `demo@example.com` / `password123`
