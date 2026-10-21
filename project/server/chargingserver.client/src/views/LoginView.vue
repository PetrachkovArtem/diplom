<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { ApiError } from '@/api/http'
import { useAuth } from '@/composables/useAuth'

const router = useRouter()
const { login } = useAuth()

const email = ref('')
const password = ref('')
const error = ref('')
const loading = ref(false)

async function onSubmit() {
  error.value = ''
  loading.value = true
  try {
    await login(email.value.trim(), password.value)
    await router.push({ name: 'users' })
  } catch (e) {
    error.value = e instanceof ApiError || e instanceof Error ? e.message : 'Не удалось войти'
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="login-page">
    <header class="admin-header">
      <div class="admin-brand">Заряди сам — администратор</div>
    </header>

    <div class="login-body">
      <form class="login-form" @submit.prevent="onSubmit">
        <h1>Вход</h1>
        <input
          v-model="email"
          class="field"
          type="email"
          placeholder="Логин"
          autocomplete="username"
          required
        />
        <input
          v-model="password"
          class="field"
          type="password"
          placeholder="Пароль"
          autocomplete="current-password"
          required
        />
        <p v-if="error" class="error-text">{{ error }}</p>
        <button class="btn btn-primary" type="submit" :disabled="loading">
          {{ loading ? 'Вход…' : 'Войти' }}
        </button>
      </form>
    </div>
  </div>
</template>
