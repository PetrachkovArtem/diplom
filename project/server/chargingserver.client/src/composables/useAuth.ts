import { computed, ref } from 'vue'
import { login as loginRequest, type LoginResponse } from '@/api/user'
import { getToken, setToken } from '@/api/http'

const AUTH_USER_KEY = 'cs_admin_user'

interface StoredUser {
  email: string
  role: string
}

const token = ref<string | null>(getToken())
const user = ref<StoredUser | null>(readStoredUser())

function readStoredUser(): StoredUser | null {
  const raw = localStorage.getItem(AUTH_USER_KEY)
  if (!raw) {
    return null
  }
  try {
    return JSON.parse(raw) as StoredUser
  } catch {
    return null
  }
}

function persist(auth: LoginResponse | null) {
  if (!auth) {
    setToken(null)
    localStorage.removeItem(AUTH_USER_KEY)
    token.value = null
    user.value = null
    return
  }

  setToken(auth.accessToken)
  const next = { email: auth.email, role: auth.role }
  localStorage.setItem(AUTH_USER_KEY, JSON.stringify(next))
  token.value = auth.accessToken
  user.value = next
}

export function useAuth() {
  const isAuthenticated = computed(() => !!token.value)
  const isAdmin = computed(() => user.value?.role === 'Admin')

  async function login(email: string, password: string) {
    const auth = await loginRequest(email, password)
    if (auth.role !== 'Admin') {
      persist(null)
      throw new Error('Доступ только для администратора')
    }
    persist(auth)
    return auth
  }

  function logout() {
    persist(null)
  }

  return {
    token,
    user,
    isAuthenticated,
    isAdmin,
    login,
    logout,
  }
}
