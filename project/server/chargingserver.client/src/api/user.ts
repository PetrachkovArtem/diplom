import { apiFetch } from './http'

export interface LoginResponse {
  accessToken: string
  email: string
  role: string
  bindToken: string
}

export function login(email: string, password: string) {
  return apiFetch<LoginResponse>('/api/user/login', {
    method: 'POST',
    body: JSON.stringify({ email, password }),
  })
}
