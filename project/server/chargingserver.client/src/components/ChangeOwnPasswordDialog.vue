<script setup lang="ts">
import { ref } from 'vue'

defineProps<{
  loading?: boolean
}>()

const emit = defineEmits<{
  cancel: []
  save: [
    payload: {
      currentPassword: string
      newPassword: string
      newPasswordRepeat: string
    },
  ]
}>()

const currentPassword = ref('')
const newPassword = ref('')
const newPasswordRepeat = ref('')
const localError = ref('')

function submit() {
  localError.value = ''
  if (!currentPassword.value) {
    localError.value = 'Укажите текущий пароль'
    return
  }
  if (newPassword.value.length < 6) {
    localError.value = 'Пароль должен содержать не менее 6 символов'
    return
  }
  if (newPassword.value !== newPasswordRepeat.value) {
    localError.value = 'Новый пароль и подтверждение не совпадают'
    return
  }
  emit('save', {
    currentPassword: currentPassword.value,
    newPassword: newPassword.value,
    newPasswordRepeat: newPasswordRepeat.value,
  })
}
</script>

<template>
  <div class="modal-backdrop" @click.self="emit('cancel')">
    <div class="modal" role="dialog" aria-modal="true">
      <h2>Смена пароля</h2>
      <p class="modal-note">
        Поле текущего пароля только для своей учётной записи администратора
      </p>
      <form @submit.prevent="submit">
        <input
          v-model="currentPassword"
          class="field"
          type="password"
          placeholder="Текущий пароль"
          autocomplete="current-password"
        />
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
