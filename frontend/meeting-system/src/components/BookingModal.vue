<template>
  <div v-if="show" class="modal-overlay" @click="close">
    <div class="modal-content" @click.stop>
      <h2>📝 Booking {{ selectedRoom.name }}</h2>

      <form @submit.prevent="submitBooking">
        <div class="form-group">
          <label>Judul Meeting:</label>
          <input
            type="text"
            v-model="formData.title"
            required
            placeholder="Contoh: Meeting Tim Marketing"
          >
        </div>

        <div class="form-group">
          <label>Waktu Mulai:</label>
          <input
            type="datetime-local"
            v-model="formData.start_time"
            required
          >
        </div>

        <div class="form-group">
          <label>Waktu Selesai:</label>
          <input
            type="datetime-local"
            v-model="formData.end_time"
            required
          >
        </div>

        <div class="form-actions">
          <button type="submit" class="btn-submit" :disabled="loading">
            {{ loading ? 'Loading...' : '✅ Buat Reservasi' }}
          </button>
          <button type="button" @click="close" class="btn-cancel">
            ❌ Batal
          </button>
        </div>
      </form>
    </div>
  </div>
</template>

<script setup>
import { ref, watch } from 'vue'
import { useApi } from '../composables/useApi'

const props = defineProps({
  show: Boolean,
  selectedRoom: Object
})

const emit = defineEmits(['close', 'success'])

const { loading, makeRequest } = useApi()
const formData = ref({
  title: '',
  start_time: '',
  end_time: ''
})

// Set default values when room changes
watch(() => props.selectedRoom, (room) => {
  if (room) {
    formData.value.title = `Meeting di ${room.name}`

    // Set default time (1-2 hours from now)
    const now = new Date()
    const startTime = new Date(now.getTime() + 60 * 60 * 1000)
    const endTime = new Date(startTime.getTime() + 60 * 60 * 1000)

    formData.value.start_time = startTime.toISOString().slice(0, 16)
    formData.value.end_time = endTime.toISOString().slice(0, 16)
  }
})

const close = () => {
  emit('close')
}

const submitBooking = async () => {
  const result = await makeRequest('/api/api/reservations.php', {
    method: 'POST',
    body: JSON.stringify({
      room_id: props.selectedRoom.id,
      ...formData.value
    })
  })

  if (result.success) {
    emit('success', result.message)
    close()
  } else {
    alert(result.error)
  }
}
</script>

<style scoped>
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0,0,0,0.5);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
}

.modal-content {
  background: white;
  padding: 30px;
  border-radius: 8px;
  width: 90%;
  max-width: 500px;
}

.form-group {
  margin-bottom: 15px;
}

.form-group label {
  display: block;
  margin-bottom: 5px;
  font-weight: bold;
}

.form-group input {
  width: 100%;
  padding: 8px;
  border: 1px solid #ddd;
  border-radius: 4px;
}

.form-actions {
  display: flex;
  gap: 10px;
  margin-top: 20px;
}

.btn-submit {
  background: #28a745;
  color: white;
  border: none;
  padding: 10px 15px;
  border-radius: 4px;
  cursor: pointer;
  flex: 1;
}

.btn-submit:disabled {
  background: #6c757d;
  cursor: not-allowed;
}

.btn-cancel {
  background: #dc3545;
  color: white;
  border: none;
  padding: 10px 15px;
  border-radius: 4px;
  cursor: pointer;
  flex: 1;
}
</style>
