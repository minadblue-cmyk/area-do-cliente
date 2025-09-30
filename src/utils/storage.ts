const KEY_STORAGE = 'area:enc-key'

async function getCryptoKey(): Promise<CryptoKey | null> {
  try {
    const existing = localStorage.getItem(KEY_STORAGE)
    let raw: Uint8Array
    if (existing) {
      raw = Uint8Array.from(atob(existing), c => c.charCodeAt(0))
    } else {
      raw = crypto.getRandomValues(new Uint8Array(32))
      localStorage.setItem(KEY_STORAGE, btoa(String.fromCharCode(...raw)))
    }
    return await crypto.subtle.importKey('raw', raw, { name: 'AES-GCM' }, false, ['encrypt', 'decrypt'])
  } catch {
    return null
  }
}

async function encrypt(value: string): Promise<string> {
  const key = await getCryptoKey()
  if (!key || !window.isSecureContext) {
    return btoa(unescape(encodeURIComponent(value)))
  }
  const iv = crypto.getRandomValues(new Uint8Array(12))
  const enc = new TextEncoder().encode(value)
  const buf = await crypto.subtle.encrypt({ name: 'AES-GCM', iv }, key, enc)
  const merged = new Uint8Array(iv.byteLength + buf.byteLength)
  merged.set(iv, 0)
  merged.set(new Uint8Array(buf), iv.byteLength)
  return btoa(String.fromCharCode(...merged))
}

async function decrypt(value: string): Promise<string> {
  const key = await getCryptoKey()
  if (!key || !window.isSecureContext) {
    return decodeURIComponent(escape(atob(value)))
  }
  const raw = Uint8Array.from(atob(value), c => c.charCodeAt(0))
  const iv = raw.slice(0, 12)
  const data = raw.slice(12)
  const buf = await crypto.subtle.decrypt({ name: 'AES-GCM', iv }, key, data)
  return new TextDecoder().decode(buf)
}

export const secureStorage = {
  async set(key: string, value: unknown) {
    try {
      const json = JSON.stringify(value)
      const enc = await encrypt(json)
      localStorage.setItem(key, enc)
    } catch {}
  },
  async get<T>(key: string): Promise<T | null> {
    try {
      const raw = localStorage.getItem(key)
      if (!raw) return null
      const dec = await decrypt(raw)
      return JSON.parse(dec) as T
    } catch {
      return null
    }
  },
  remove(key: string) {
    try { localStorage.removeItem(key) } catch {}
  }
}
