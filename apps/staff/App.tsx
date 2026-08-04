import { useState } from 'react'
import {
  SafeAreaView,
  StyleSheet,
  Text,
  TextInput,
  Pressable,
  View,
  ScrollView
} from 'react-native'
import { StatusBar } from 'expo-status-bar'

// 開発時は実機の到達可能なホストに差し替える
const API_BASE = 'http://10.0.2.2:3000'

type User = {
  id: number
  email: string
  qr_token: string
  basic_info: string | null
}

export default function App() {
  const [email, setEmail] = useState('demo@example.com')
  const [password, setPassword] = useState('password123')
  const [token, setToken] = useState<string | null>(null)
  const [user, setUser] = useState<User | null>(null)
  const [log, setLog] = useState<string>('未ログイン')

  async function login() {
    try {
      const res = await fetch(`${API_BASE}/api/v1/auth/login`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email, password, device_id: 'staff-dev' })
      })
      const json = await res.json()
      if (!json.ok) {
        setLog(`ログイン失敗: ${json.error}`)
        return
      }
      setToken(json.token)
      setUser(json.user)
      setLog('ログイン成功')
    } catch (e) {
      setLog(`通信エラー: ${String(e)}`)
    }
  }

  async function startSession() {
    if (!token || !user) return
    try {
      const res = await fetch(`${API_BASE}/api/v1/recording_sessions`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${token}`
        },
        body: JSON.stringify({ qr_token: user.qr_token })
      })
      const json = await res.json()
      if (!json.ok) {
        setLog(`セッション失敗: ${json.error}`)
        return
      }
      setLog(`セッション開始 #${json.recording_session.id}`)
    } catch (e) {
      setLog(`通信エラー: ${String(e)}`)
    }
  }

  return (
    <SafeAreaView style={styles.root}>
      <StatusBar style="dark" />
      <ScrollView contentContainerStyle={styles.pad}>
        <Text style={styles.title}>語り継ぎ Staff（STEP A）</Text>
        <Text style={styles.hint}>骨格: ログイン ＋ QR 相当のセッション開始</Text>

        <Text style={styles.label}>メール</Text>
        <TextInput style={styles.input} autoCapitalize="none" value={email} onChangeText={setEmail} />
        <Text style={styles.label}>パスワード</Text>
        <TextInput style={styles.input} secureTextEntry value={password} onChangeText={setPassword} />

        <Pressable style={styles.btn} onPress={login}>
          <Text style={styles.btnText}>ログイン</Text>
        </Pressable>

        {user ? (
          <View style={styles.card}>
            <Text>User: {user.email}</Text>
            <Text>QR: {user.qr_token}</Text>
            <Pressable style={styles.btn} onPress={startSession}>
              <Text style={styles.btnText}>自分の QR でセッション開始</Text>
            </Pressable>
            <Text style={styles.hint}>音声・画像アップロード／カメラ QR は次タスク</Text>
          </View>
        ) : null}

        <Text style={styles.log}>{log}</Text>
      </ScrollView>
    </SafeAreaView>
  )
}

const styles = StyleSheet.create({
  root: { flex: 1, backgroundColor: '#f6f4ef' },
  pad: { padding: 20, gap: 8 },
  title: { fontSize: 22, fontWeight: '700', marginBottom: 4 },
  hint: { color: '#57534e', marginBottom: 8 },
  label: { marginTop: 8, fontWeight: '600' },
  input: {
    borderWidth: 1,
    borderColor: '#d6d3d1',
    borderRadius: 8,
    padding: 10,
    backgroundColor: '#fff'
  },
  btn: {
    marginTop: 12,
    backgroundColor: '#1c1917',
    padding: 12,
    borderRadius: 8,
    alignItems: 'center'
  },
  btnText: { color: '#fff', fontWeight: '600' },
  card: { marginTop: 16, padding: 12, backgroundColor: '#fff', borderRadius: 8, gap: 8 },
  log: { marginTop: 16, fontFamily: 'monospace' }
})
