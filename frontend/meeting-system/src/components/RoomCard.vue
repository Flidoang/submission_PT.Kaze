<template>
  <div
    class="bg-white rounded-xl shadow-md hover:shadow-lg transition-all duration-300 border border-gray-200 hover:border-blue-300 p-6 cursor-pointer"
    @click="$emit('book', room)"
  >
    <!-- Room Header -->
    <div class="flex justify-between items-start mb-4">
      <h3 class="text-xl font-bold text-gray-800">{{ room.name }}</h3>
      <span class="bg-blue-100 text-blue-800 text-sm font-medium px-2.5 py-0.5 rounded-full">
        {{ room.capacity }} orang
      </span>
    </div>

    <!-- Facilities -->
    <div class="mb-4">
      <p class="text-gray-600 text-sm mb-2 flex items-center">
        <span class="mr-2">🛠️</span>
        <span class="font-medium">Fasilitas:</span>
      </p>
      <p class="text-gray-700 text-sm pl-6">{{ room.facilities }}</p>
    </div>

    <!-- Today's Schedule -->
    <div class="mb-4">
      <p class="text-gray-600 text-sm mb-2 flex items-center">
        <span class="mr-2">📅</span>
        <span class="font-medium">Jadwal Hari Ini:</span>
      </p>
      <div v-if="todayReservations.length === 0" class="text-gray-400 text-sm pl-6 italic">
        Tidak ada booking
      </div>
      <div v-else class="space-y-1 pl-6">
        <div
          v-for="reservation in todayReservations"
          :key="reservation.id"
          class="bg-blue-50 text-blue-700 text-xs px-2 py-1 rounded flex items-center"
        >
          <span class="mr-2">⏰</span>
          {{ formatTime(reservation.start_time) }} - {{ formatTime(reservation.end_time) }}
        </div>
      </div>
    </div>

    <!-- Book Button -->
    <button class="w-full bg-blue-600 hover:bg-blue-700 text-white font-medium py-3 px-4 rounded-lg transition-colors duration-200 flex items-center justify-center">
      <span class="mr-2">📅</span>
      Booking Sekarang
    </button>
  </div>
</template>

<script setup>
import { computed } from 'vue'

// Props
const props = defineProps({
  room: {
    type: Object,
    required: true
  },
  reservations: {
    type: Array,
    default: () => []
  }
})

// Emits
defineEmits(['book'])

// Computed
const todayReservations = computed(() => {
  const today = new Date().toISOString().split('T')[0]
  return props.reservations.filter(reservation =>
    reservation.room_id === props.room.id &&
    reservation.start_time.startsWith(today) &&
    reservation.status === 'confirmed'
  )
})

// Methods
const formatTime = (datetime) => {
  return new Date(datetime).toLocaleTimeString('id-ID', {
    hour: '2-digit',
    minute: '2-digit'
  })
}
</script>
