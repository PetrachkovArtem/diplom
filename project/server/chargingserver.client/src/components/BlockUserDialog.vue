<script setup lang="ts">
import type { AdminUser } from '@/api/admin'

const props = defineProps<{
  user: AdminUser
  loading?: boolean
}>()

const emit = defineEmits<{
  cancel: []
  confirm: []
}>()

const title = props.user.isBlocked ? 'Разблокировка' : 'Блокировка'
const action = props.user.isBlocked ? 'Разблокировать' : 'Заблокировать'
const question = props.user.isBlocked
  ? `Разблокировать пользователя ${props.user.email}?`
  : `Заблокировать пользователя ${props.user.email}?`
</script>

<template>
  <div class="modal-backdrop" @click.self="emit('cancel')">
    <div class="modal" role="dialog" aria-modal="true">
      <h2>{{ title }}</h2>
      <p>{{ question }}</p>
      <div class="modal-actions">
        <button type="button" class="btn btn-secondary" :disabled="loading" @click="emit('cancel')">
          Отмена
        </button>
        <button type="button" class="btn btn-primary" :disabled="loading" @click="emit('confirm')">
          {{ action }}
        </button>
      </div>
    </div>
  </div>
</template>
