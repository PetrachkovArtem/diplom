<script setup lang="ts">
import { computed, onMounted, ref, watch } from 'vue'
import { useRouter } from 'vue-router'
import {
  changeOwnPassword,
  listUsers,
  resetPassword,
  setBlocked,
  type AdminUser,
} from '@/api/admin'
import { ApiError } from '@/api/http'
import BlockUserDialog from '@/components/BlockUserDialog.vue'
import ChangeOwnPasswordDialog from '@/components/ChangeOwnPasswordDialog.vue'
import ResetPasswordDialog from '@/components/ResetPasswordDialog.vue'
import { useAuth } from '@/composables/useAuth'

const router = useRouter()
const { logout } = useAuth()

const users = ref<AdminUser[]>([])
const page = ref(1)
const pageSize = 20
const total = ref(0)
const search = ref('')
const loading = ref(false)
const error = ref('')
const success = ref('')
const actionLoading = ref(false)

const blockTarget = ref<AdminUser | null>(null)
const resetTarget = ref<AdminUser | null>(null)
const ownPasswordOpen = ref(false)

let searchTimer: ReturnType<typeof setTimeout> | null = null

const totalPages = computed(() => Math.max(1, Math.ceil(total.value / pageSize)))

function formatDate(value: string) {
  const date = new Date(value)
  if (Number.isNaN(date.getTime())) {
    return value
  }
  const pad = (n: number) => String(n).padStart(2, '0')
  return `${pad(date.getDate())}.${pad(date.getMonth() + 1)}.${date.getFullYear()} ${pad(date.getHours())}:${pad(date.getMinutes())}`
}

async function loadUsers() {
  loading.value = true
  error.value = ''
  try {
    const result = await listUsers(search.value, page.value, pageSize)
    users.value = result.items
    total.value = result.total
    page.value = result.page
  } catch (e) {
    error.value = e instanceof ApiError ? e.message : 'Не удалось загрузить пользователей'
  } finally {
    loading.value = false
  }
}

function onSearchInput() {
  if (searchTimer) {
    clearTimeout(searchTimer)
  }
  searchTimer = setTimeout(() => {
    page.value = 1
    void loadUsers()
  }, 300)
}

function goToPage(next: number) {
  if (next < 1 || next > totalPages.value || next === page.value) {
    return
  }
  page.value = next
  void loadUsers()
}

async function onLogout() {
  logout()
  await router.push({ name: 'login' })
}

async function confirmBlock() {
  if (!blockTarget.value) {
    return
  }
  actionLoading.value = true
  error.value = ''
  success.value = ''
  try {
    await setBlocked(blockTarget.value.id, !blockTarget.value.isBlocked)
    success.value = blockTarget.value.isBlocked ? 'Пользователь разблокирован' : 'Пользователь заблокирован'
    blockTarget.value = null
    await loadUsers()
  } catch (e) {
    error.value = e instanceof ApiError ? e.message : 'Не удалось изменить блокировку'
  } finally {
    actionLoading.value = false
  }
}

async function saveResetPassword(payload: { newPassword: string; newPasswordRepeat: string }) {
  if (!resetTarget.value) {
    return
  }
  actionLoading.value = true
  error.value = ''
  success.value = ''
  try {
    await resetPassword(resetTarget.value.id, payload.newPassword, payload.newPasswordRepeat)
    success.value = 'Пароль пользователя обновлён'
    resetTarget.value = null
  } catch (e) {
    error.value = e instanceof ApiError ? e.message : 'Не удалось сменить пароль'
  } finally {
    actionLoading.value = false
  }
}

async function saveOwnPassword(payload: {
  currentPassword: string
  newPassword: string
  newPasswordRepeat: string
}) {
  actionLoading.value = true
  error.value = ''
  success.value = ''
  try {
    await changeOwnPassword(payload.currentPassword, payload.newPassword, payload.newPasswordRepeat)
    success.value = 'Ваш пароль изменён'
    ownPasswordOpen.value = false
  } catch (e) {
    error.value = e instanceof ApiError ? e.message : 'Не удалось сменить пароль'
  } finally {
    actionLoading.value = false
  }
}

onMounted(() => {
  void loadUsers()
})

watch(search, onSearchInput)
</script>

<template>
  <div>
    <header class="admin-header">
      <div class="admin-brand">Заряди сам — администратор</div>
      <div class="admin-header-actions">
        <button type="button" class="btn btn-secondary btn-sm" @click="ownPasswordOpen = true">
          Сменить свой пароль
        </button>
        <button type="button" class="btn btn-secondary btn-sm" @click="onLogout">Выйти</button>
      </div>
    </header>

    <main class="page">
      <h1 class="page-title">Пользователи</h1>

      <input
        v-model="search"
        class="field search-field"
        type="search"
        placeholder="Поиск по адресу электронной почты"
      />

      <p v-if="error" class="error-text">{{ error }}</p>
      <p v-if="success" class="success-text">{{ success }}</p>

      <div class="table-wrap">
        <table class="users-table">
          <thead>
            <tr>
              <th>Почта</th>
              <th>Блокировка</th>
              <th>Создан</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            <tr v-if="loading">
              <td colspan="4" class="empty-state">Загрузка…</td>
            </tr>
            <tr v-else-if="users.length === 0">
              <td colspan="4" class="empty-state">Пользователи не найдены</td>
            </tr>
            <tr v-for="user in users" :key="user.id">
              <td>{{ user.email }}</td>
              <td>
                <span class="badge" :class="user.isBlocked ? 'badge-yes' : 'badge-no'">
                  {{ user.isBlocked ? 'Да' : 'Нет' }}
                </span>
              </td>
              <td>{{ formatDate(user.createdAt) }}</td>
              <td>
                <div class="row-actions">
                  <button type="button" class="btn btn-secondary btn-sm" @click="blockTarget = user">
                    {{ user.isBlocked ? 'Разблокировать' : 'Заблокировать' }}
                  </button>
                  <button type="button" class="btn btn-secondary btn-sm" @click="resetTarget = user">
                    Сменить пароль
                  </button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <div v-if="totalPages > 1" class="pagination">
        <button
          v-for="n in totalPages"
          :key="n"
          type="button"
          class="page-btn"
          :class="{ active: n === page }"
          @click="goToPage(n)"
        >
          {{ n }}
        </button>
      </div>
    </main>

    <BlockUserDialog
      v-if="blockTarget"
      :user="blockTarget"
      :loading="actionLoading"
      @cancel="blockTarget = null"
      @confirm="confirmBlock"
    />

    <ResetPasswordDialog
      v-if="resetTarget"
      :user="resetTarget"
      :loading="actionLoading"
      @cancel="resetTarget = null"
      @save="saveResetPassword"
    />

    <ChangeOwnPasswordDialog
      v-if="ownPasswordOpen"
      :loading="actionLoading"
      @cancel="ownPasswordOpen = false"
      @save="saveOwnPassword"
    />
  </div>
</template>
