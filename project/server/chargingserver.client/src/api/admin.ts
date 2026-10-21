import { apiFetch } from './http'

export interface AdminUser {
  id: string
  email: string
  isBlocked: boolean
  createdAt: string
  role: string
}

export interface PagedResult<T> {
  items: T[]
  page: number
  pageSize: number
  total: number
}

export function listUsers(email: string, page: number, pageSize = 20) {
  const params = new URLSearchParams({
    page: String(page),
    pageSize: String(pageSize),
  })
  if (email.trim()) {
    params.set('email', email.trim())
  }
  return apiFetch<PagedResult<AdminUser>>(`/api/admin/users?${params}`)
}

export function setBlocked(id: string, isBlocked: boolean) {
  return apiFetch<void>(`/api/admin/users/${id}/block`, {
    method: 'POST',
    body: JSON.stringify({ isBlocked }),
  })
}

export function resetPassword(id: string, newPassword: string, newPasswordRepeat: string) {
  return apiFetch<void>(`/api/admin/users/${id}/reset-password`, {
    method: 'POST',
    body: JSON.stringify({ newPassword, newPasswordRepeat }),
  })
}

export function changeOwnPassword(
  currentPassword: string,
  newPassword: string,
  newPasswordRepeat: string,
) {
  return apiFetch<void>('/api/admin/me/password', {
    method: 'POST',
    body: JSON.stringify({ currentPassword, newPassword, newPasswordRepeat }),
  })
}
