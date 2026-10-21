<script setup lang="ts">
import { ref } from 'vue'
import type { AdminUser } from '@/api/admin'

defineProps<{
  user: AdminUser
  loading?: boolean
}>()

const emit = defineEmits<{
  cancel: []
  save: [payload: { newPassword: string; newPasswordRepeat: string }]
}>()

const newPassword = ref('')
const newPasswordRepeat = ref('')
const localError = ref('')

function submit() {
  localError.value = ''
  if (newPassword.value.length < 6) {
    localError.value = 'Пароль должен содержать не менее 6 символов'
    return
  }
  if (newPassword.value !== newPasswordRepeat.value) {
    localError.value = 'Новый пароль и подтверждение не совпадают'
    return
  }
  emit('save', {
    newPassword: newPassword.value,
    newPasswordRepeat: newPasswordRepeat.value,
  })
}
</script>

<template>
  <div class="modal-backdrop" @click.self="emit('cancel')">
    <div class="modal" role="dialog" aria-modal="true">
      <h2>Смена пароля</h2>
      <p>Новый пароль для пользователя {{ user.email }}</p>
      <form @submit.prevent="submit">
        <input
          v-model="newPassword"
          class="field"
          type="password"
          placeholder="Новый пароль"
          autocomplete="new-password"
        />
        <input
          v-model="newPasswordRepeat"
          class="field"
          type="password"
          placeholder="Подтверждение нового пароля"
          autocomplete="new-password"
        />
        <p v-if="localError" class="error-text">{{ localError }}</p>
        <div class="modal-actions">
          <button type="button" class="btn btn-secondary" :disabled="loading" @click="emit('cancel')">
            Отмена
          </button>
          <button type="submit" class="btn btn-primary" :disabled="loading">Сохранить</button>
        </div>
      </form>
    </div>
  </div>
</template>
