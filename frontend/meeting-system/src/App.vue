<template>
  <div class="min-h-screen bg-gray-50">
    <div class="container mx-auto px-4 py-8">
      <!-- Header dengan Login/User Info -->
      <div class="flex justify-between items-center mb-8 pb-6 border-b border-gray-200">
        <h1 class="text-3xl font-bold text-gray-800">🏢 Sistem Reservasi Ruang Rapat</h1>

        <div v-if="!store.isAuthenticated" class="auth-section">
          <button
            @click="showLoginModal = true"
            class="bg-green-600 hover:bg-green-700 text-white font-medium py-2 px-4 rounded-lg transition-colors duration-200 flex items-center"
          >
            <span class="mr-2">🔐</span>
            Login
          </button>
        </div>

        <div v-else class="user-info flex items-center gap-4">
          <span class="text-gray-700">
            Halo, <strong class="text-gray-900">{{ store.user.name }}</strong>
          </span>
          <button
            @click="handleLogout"
            class="bg-red-600 hover:bg-red-700 text-white font-medium py-2 px-4 rounded-lg transition-colors duration-200 flex items-center"
          >
            <span class="mr-2">🚪</span>
            Logout
          </button>
        </div>
      </div>

      <!-- Content hanya muncul jika sudah login -->
      <div v-if="store.isAuthenticated">
        <!-- Simple Tabs -->
        <div class="flex gap-2 mb-8 border-b border-gray-200">
          <button
            @click="activeTab = 'rooms'"
            :class="[
              'py-3 px-6 font-medium text-sm rounded-t-lg border-b-2 transition-colors duration-200',
              activeTab === 'rooms'
                ? 'border-blue-500 text-blue-600 bg-blue-50'
                : 'border-transparent text-gray-500 hover:text-gray-700 hover:bg-gray-100'
            ]"
          >
            📋 Ruangan
          </button>
          <button
            @click="activeTab = 'history'"
            :class="[
              'py-3 px-6 font-medium text-sm rounded-t-lg border-b-2 transition-colors duration-200',
              activeTab === 'history'
                ? 'border-blue-500 text-blue-600 bg-blue-50'
                : 'border-transparent text-gray-500 hover:text-gray-700 hover:bg-gray-100'
            ]"
          >
            📖 Riwayat Saya
          </button>
        </div>

        <!-- Rooms Content -->
        <div v-if="activeTab === 'rooms'">
          <div v-if="store.loading" class="text-center py-12">
            <div class="inline-block animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
            <p class="text-gray-600 mt-4 text-lg">Loading ruangan...</p>
          </div>
          <div v-else class="rooms-grid">
            <RoomCard
              v-for="room in store.rooms"
              :key="room.id"
              :room="room"
              :reservations="allReservations"
              @book="openBookingModal"
            />
          </div>
        </div>

        <!-- History Content -->
        <div v-else>
          <div v-if="store.myReservations.length === 0" class="text-center py-16">
            <div class="text-6xl mb-4">📭</div>
            <p class="text-gray-600 text-xl mb-2">Belum ada reservasi</p>
            <p class="text-gray-400">Booking ruangan terlebih dahulu di tab "Ruangan"</p>
          </div>
          <div v-else class="space-y-4">
            <div
              v-for="reservation in store.myReservations"
              :key="reservation.id"
              :class="[
                'bg-white rounded-lg shadow-sm border p-6 transition-all duration-200 hover:shadow-md',
                reservation.status === 'cancelled' ? 'opacity-60 bg-gray-50' : ''
              ]"
            >
              <div class="flex justify-between items-start">
                <div class="flex-1">
                  <h3 class="text-xl font-semibold text-gray-800 mb-2">{{ reservation.title }}</h3>
                  <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 text-sm">
                    <p class="flex items-center text-gray-600">
                      <span class="mr-2">📍</span>
                      <span class="font-medium">Ruangan:</span>
                      <span class="ml-1 text-gray-800">{{ reservation.room_name }}</span>
                    </p>
                    <p class="flex items-center text-gray-600">
                      <span class="mr-2">📅</span>
                      <span class="font-medium">Tanggal:</span>
                      <span class="ml-1 text-gray-800">{{ formatDate(reservation.start_time) }}</span>
                    </p>
                    <p class="flex items-center text-gray-600">
                      <span class="mr-2">⏰</span>
                      <span class="font-medium">Waktu:</span>
                      <span class="ml-1 text-gray-800">
                        {{ formatTime(reservation.start_time) }} - {{ formatTime(reservation.end_time) }}
                      </span>
                    </p>
                    <p class="flex items-center" :class="reservation.status === 'confirmed' ? 'text-green-600' : 'text-red-600'">
                      <span class="mr-2 font-medium">Status:</span>
                      {{ reservation.status === 'confirmed' ? '✅ Dikonfirmasi' : '❌ Dibatalkan' }}
                    </p>
                  </div>
                </div>
                <div v-if="reservation.status === 'confirmed'" class="ml-4">
                  <button
                    @click.stop="cancelReservation(reservation.id)"
                    class="bg-red-600 hover:bg-red-700 text-white font-medium py-2 px-4 rounded-lg transition-colors duration-200 flex items-center text-sm"
                  >
                    <span class="mr-2">🗑️</span>
                    Batalkan
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Booking Modal -->
        <div v-if="showBookingModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
          <div class="bg-white rounded-xl shadow-2xl max-w-md w-full mx-auto" @click.stop>
            <div class="p-6 border-b border-gray-200">
              <h2 class="text-2xl font-bold text-gray-800 flex items-center">
                <span class="mr-2">📝</span>
                Booking {{ selectedRoom.name }}
              </h2>
            </div>

            <div class="p-6 space-y-4">
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Judul Meeting:</label>
                <input
                  v-model="bookingTitle"
                  placeholder="Contoh: Meeting Tim Marketing"
                  type="text"
                  class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                >
              </div>

              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Waktu Mulai:</label>
                <input
                  v-model="bookingStart"
                  type="datetime-local"
                  class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                >
              </div>

              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Waktu Selesai:</label>
                <input
                  v-model="bookingEnd"
                  type="datetime-local"
                  class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                >
              </div>
            </div>

            <div class="p-6 border-t border-gray-200 flex gap-3">
              <button
                @click="submitBooking"
                :disabled="bookingLoading"
                :class="[
                  'flex-1 py-3 px-4 rounded-lg font-medium transition-colors duration-200 flex items-center justify-center',
                  bookingLoading
                    ? 'bg-gray-400 cursor-not-allowed text-white'
                    : 'bg-green-600 hover:bg-green-700 text-white'
                ]"
              >
                <span class="mr-2">{{ bookingLoading ? '⏳' : '✅' }}</span>
                {{ bookingLoading ? 'Memproses...' : 'Buat Reservasi' }}
              </button>
              <button
                @click="closeBookingModal"
                class="flex-1 py-3 px-4 bg-gray-500 hover:bg-gray-600 text-white rounded-lg font-medium transition-colors duration-200"
              >
                ❌ Batal
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Login Modal -->
      <div v-if="showLoginModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
        <div class="bg-white rounded-xl shadow-2xl max-w-md w-full mx-auto" @click.stop>
          <div class="p-6 border-b border-gray-200">
            <h2 class="text-2xl font-bold text-gray-800 flex items-center">
              <span class="mr-2">🔐</span>
              Login
            </h2>
          </div>

          <div class="p-6 space-y-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">Email:</label>
              <input
                v-model="loginEmail"
                type="email"
                placeholder="john@company.com"
                class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              >
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">Password:</label>
              <input
                v-model="loginPassword"
                type="password"
                placeholder="123456"
                class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              >
            </div>

            <div class="bg-blue-50 border-l-4 border-blue-500 p-4 rounded">
              <p class="font-medium text-blue-800 mb-2">🔑 Akun Demo:</p>
              <div class="text-sm text-blue-700 space-y-1">
                <p>📧 john@company.com</p>
                <p>📧 jane@company.com</p>
                <p>📧 bob@company.com</p>
                <p class="font-semibold">🔐 Password: 123456</p>
              </div>
            </div>
          </div>

          <div class="p-6 border-t border-gray-200 flex gap-3">
            <button
              @click="handleLogin"
              :disabled="loginLoading"
              :class="[
                'flex-1 py-3 px-4 rounded-lg font-medium transition-colors duration-200 flex items-center justify-center',
                loginLoading
                  ? 'bg-gray-400 cursor-not-allowed text-white'
                  : 'bg-green-600 hover:bg-green-700 text-white'
              ]"
            >
              <span class="mr-2">{{ loginLoading ? '⏳' : '🚀' }}</span>
              {{ loginLoading ? 'Loading...' : 'Login' }}
            </button>
            <button
              @click="showLoginModal = false"
              class="flex-1 py-3 px-4 bg-gray-500 hover:bg-gray-600 text-white rounded-lg font-medium transition-colors duration-200"
            >
              Batal
            </button>
          </div>
        </div>
      </div>

      <!-- Global Message -->
      <div
        v-if="message"
        :class="[
          'fixed top-4 right-4 z-50 px-6 py-4 rounded-lg shadow-lg font-medium transition-all duration-300',
          isError
            ? 'bg-red-100 border-l-4 border-red-500 text-red-700'
            : 'bg-green-100 border-l-4 border-green-500 text-green-700'
        ]"
      >
        {{ message }}
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue'
import { useReservationStore } from './stores/reservationStore'
import RoomCard from './components/RoomCard.vue'

const store = useReservationStore()

// State untuk UI
const activeTab = ref('rooms')
const showBookingModal = ref(false)
const showLoginModal = ref(false)
const selectedRoom = ref(null)
const allReservations = ref([])

// State untuk form booking
const bookingTitle = ref('')
const bookingStart = ref('')
const bookingEnd = ref('')
const bookingLoading = ref(false)

// State untuk login
const loginEmail = ref('')
const loginPassword = ref('')
const loginLoading = ref(false)

// State untuk message
const message = ref('')
const isError = ref(false)

// Check auth status saat app load
onMounted(async () => {
  await store.checkAuth()
  if (store.isAuthenticated) {
    await store.fetchRooms()
    await fetchAllReservations()
  }
})

// Fetch semua reservations untuk RoomCard
const fetchAllReservations = async () => {
  try {
    const response = await fetch('http://localhost/meeting-system/backend/api/reservations.php', {
      credentials: 'include'
    })
    const result = await response.json()
    if (result.success) {
      allReservations.value = result.data
    }
  } catch (error) {
    console.error('Error fetching all reservations:', error)
  }
}

// Ketika tab history dipilih, load reservations
watch(activeTab, (newTab) => {
  if (newTab === 'history' && store.isAuthenticated) {
    store.fetchMyReservations()
  }
})

// === AUTH METHODS ===
const handleLogin = async () => {
  if (!loginEmail.value || !loginPassword.value) {
    showMessage('Email dan password harus diisi', true)
    return
  }

  loginLoading.value = true
  const result = await store.login(loginEmail.value, loginPassword.value)
  loginLoading.value = false

  if (result.success) {
    showLoginModal.value = false
    loginEmail.value = ''
    loginPassword.value = ''
    showMessage('Login berhasil! 🎉')
    await store.fetchRooms()
    await fetchAllReservations() // ✅ LOAD SETELAH LOGIN
  } else {
    showMessage('Login gagal: ' + result.error, true)
  }
}

const handleLogout = () => {
  store.logout()
  showMessage('Anda telah logout')
  activeTab.value = 'rooms'
}

// === BOOKING METHODS ===
const openBookingModal = (room) => {
  selectedRoom.value = room
  bookingTitle.value = `Meeting di ${room.name}`

  // Set default waktu (1-2 jam dari sekarang)
  const now = new Date()
  const start = new Date(now.getTime() + 60 * 60 * 1000) // 1 jam dari sekarang
  const end = new Date(start.getTime() + 60 * 60 * 1000) // 2 jam dari sekarang

  bookingStart.value = start.toISOString().slice(0, 16)
  bookingEnd.value = end.toISOString().slice(0, 16)

  showBookingModal.value = true
}

const closeBookingModal = () => {
  showBookingModal.value = false
  selectedRoom.value = null
  bookingTitle.value = ''
  bookingStart.value = ''
  bookingEnd.value = ''
}

const submitBooking = async () => {
  if (!bookingTitle.value || !bookingStart.value || !bookingEnd.value) {
    showMessage('Harap isi semua field', true)
    return
  }

  bookingLoading.value = true
  try {
    const response = await fetch('http://localhost/meeting-system/backend/api/reservations.php', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      credentials: 'include',
      body: JSON.stringify({
        room_id: selectedRoom.value.id,
        title: bookingTitle.value,
        start_time: bookingStart.value,
        end_time: bookingEnd.value
      })
    })

    const result = await response.json()

    if (result.success) {
      showMessage(result.message)
      closeBookingModal()
      await store.fetchRooms()
      await fetchAllReservations() // ✅ REFRESH SETELAH BOOKING
      activeTab.value = 'history'
      await store.fetchMyReservations()
    } else {
      showMessage(result.error, true)
    }
  } catch (error) {
    showMessage('Gagal membuat reservasi: ' + error.message, true)
  }
  bookingLoading.value = false
}

const cancelReservation = async (reservationId) => {
  if (!confirm('Yakin ingin membatalkan reservasi ini?')) {
    return
  }

  try {
    const response = await fetch('http://localhost/meeting-system/backend/api/reservations.php', {
      method: 'DELETE',
      headers: {
        'Content-Type': 'application/json',
      },
      credentials: 'include',
      body: JSON.stringify({
        reservation_id: reservationId
      })
    })

    const result = await response.json()

    if (result.success) {
      showMessage(result.message)
      await store.fetchMyReservations()
      await store.fetchRooms()
      await fetchAllReservations()
    } else {
      showMessage(result.error, true)
    }
  } catch (error) {
    showMessage('Gagal membatalkan reservasi: ' + error.message, true)
  }
}

// === UTILITY METHODS ===
const formatTime = (datetime) => {
  return new Date(datetime).toLocaleTimeString('id-ID', {
    hour: '2-digit',
    minute: '2-digit'
  })
}

const formatDate = (datetime) => {
  return new Date(datetime).toLocaleDateString('id-ID', {
    weekday: 'long',
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  })
}

const showMessage = (msg, error = false) => {
  message.value = msg
  isError.value = error
  setTimeout(() => {
    message.value = ''
  }, 5000)
}
</script>

<style scoped>
.rooms-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
  gap: 1.5rem;
}
</style>


