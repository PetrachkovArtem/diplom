import { apiFetch } from './http'

export interface AuthResponse {
  accessToken: string
  email: string
  role: string
  bindToken: string
}

export function login(email: string, password: string) {
  return apiFetch<AuthResponse>('/api/auth/login', {
    method: 'POST',
    body: JSON.stringify({ email, password }),
  })
}
